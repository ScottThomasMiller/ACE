//
//  Headset.swift
//
//  Created by Scott Miller for Aeris Rising, LLC on 8/27/21.
//

import Foundation
import SwiftUI
import BrainFlow

enum GainSettings: String, CaseIterable {
    case x1 = "00"
    case x2 = "01"
    case x4 = "02"
    case x6 = "03"
    case x8 = "04"
    case x12 = "05"
    case x24 = "06"
}

enum ChannelIDs: String, CaseIterable {
    case channel1 = "1"
    case channel2 = "2"
    case channel3 = "3"
    case channel4 = "4"
    case channel5 = "5"
    case channel6 = "6"
    case channel7 = "7"
    case channel8 = "8"
    case channel9 = "Q"
    case channel10 = "W"
    case channel11 = "E"
    case channel12 = "R"
    case channel13 = "T"
    case channel14 = "Y"
    case channel15 = "U"
    case channel16 = "I"
}

let cytons: [BoardIds] = [.CYTON_BOARD, .CYTON_DAISY_BOARD]
let brainbits: [BoardIds] = [.BRAINBIT_BOARD, .BRAINBIT_BLED_BOARD]

class Headset {
    let uuid = UUID()
    var isStreaming: Bool = false
    var isActive: Bool = true
    let params: BrainFlowInputParams
    private var rawFile: FileHandle?
    private var filteredFile: FileHandle?
    var boardId: BoardIds
    var board: BoardShim?
    var saveURL: URL?
    let samplingRate: Int32
    let eegChannels: [Int32]
    let pkgIDchannel: Int
    let timestampChannel: Int
    let markerChannel: Int


    init(boardId: BoardIds) throws {
        self.boardId = boardId
        
        do {
            try? BoardShim.logMessage(.LEVEL_INFO, "Headset.init() UUID: \(self.uuid) boardId: \(boardId)")
            self.params = BrainFlowInputParams(serial_port: Headset.scan(boardId))
            self.board = try BoardShim(boardId, params)
            self.samplingRate = try BoardShim.getSamplingRate(boardId)
            self.eegChannels = try BoardShim.getEEGchannels(boardId)
            self.markerChannel = try Int(BoardShim.getMarkerChannel(boardId))
            self.pkgIDchannel = try Int(BoardShim.getPackageNumChannel(boardId))
            self.timestampChannel = try Int(BoardShim.getTimestampChannel(boardId))
                
            try setup()
        }
        catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (.LEVEL_ERROR, bfError.message)
            try? BoardShim.logMessage (.LEVEL_ERROR, "Error code: \(bfError.errorCode)")
            throw bfError
        }
        catch {
            try? BoardShim.logMessage (.LEVEL_ERROR, "undefined exception")
            throw error
        }
    }
    
    func setup() throws {
        try? BoardShim.logMessage(.LEVEL_INFO, "Headset.setup() UUID: \(self.uuid) boardId: \(self.boardId)")
        try BoardShim.enableDevBoardLogger()
        guard board != nil else {
            try? BoardShim.logMessage(.LEVEL_ERROR, "board is nil")
            throw BrainFlowException("Uninitialized board", .BOARD_NOT_CREATED_ERROR)
        }
        
        try board!.prepareSession()
        while try !board!.isPrepared() {
            try? BoardShim.logMessage(.LEVEL_INFO, "waiting for session...")
            sleep(3)
        }
        
        if cytons.contains(self.boardId) {
            try? BoardShim.logMessage(.LEVEL_INFO, "cyton/daisy setup")
            if !setGain(setting: .x1) {
                exit(-1)
            }
            
            if !setNumChannels() {
                exit(-1)
            }
        }
        
        self.isActive = true
        DispatchQueue.global(qos: .background).async {
            self.streamEEG()
        }
    }
    
    deinit {
        try? BoardShim.logMessage(.LEVEL_INFO, "Headset.deinit() UUID: \(self.uuid) boardId: \(self.boardId)")
        cleanup()
    }

    func setGain(setting: GainSettings) -> Bool {
        guard board != nil else {
            try? BoardShim.logMessage(.LEVEL_ERROR, "setGain: board is nil")
            return false
        }
        
        let theBoard = board!
        
        var i = 0
        for channel in ChannelIDs.allCases {
            if i >= eegChannels.count {
                continue
            }
            i += 1
            let command = "x" + channel.rawValue + setting.rawValue + "0110X"
            let expected = "Success: Channel set for \(i)$$$"
            do {
                let response = try theBoard.configBoard(command)
                try BoardShim.logMessage(.LEVEL_INFO, "set \(channel) to gain value \(setting) with command \(command)")
                if (response.count > 0) && (response != expected) {
                    try BoardShim.logMessage(.LEVEL_CRITICAL, "Unexpected response:\n\(response)")
                    return false
                }
                try BoardShim.logMessage(.LEVEL_INFO, "response: \(response)")
            }
            catch {
                return false
            }
        }
        return true
    }

    func setNumChannels() -> Bool {
        guard board != nil else {
            try? BoardShim.logMessage(.LEVEL_ERROR, "setNumChannels: board is nil")
            return false
        }
        
        let theBoard = board!
        
        // send "c" for Cyton or "C" for Cyton+Daisy
        var command: String = ""
        if boardId == .CYTON_BOARD {
            command = "c" }
        else if boardId == .CYTON_DAISY_BOARD {
            command = "C"
        }
        print("setNumChannels sending: \(command)")
        
        guard let response = try? theBoard.configBoard(command) else {
            print("Error.  Cannot send command.")
            return false
        }
        
        print("response: \(response)")
        return true
    }

    func openNewFiles()  {
        try? BoardShim.logMessage(.LEVEL_INFO, "Opening new files")
        if rawFile != nil {
            try? rawFile!.close()
            try? filteredFile!.close() }
        let uqID = CSVFile.uniqueID()
        rawFile = CSVFile(fileName: "BrainWave-EEG-Raw").create(id: uqID, saveFolder: saveURL)
        filteredFile = CSVFile(fileName: "BrainWave-EEG-Filtered").create(id: uqID, saveFolder: saveURL)
        writeHeaders()
    }
    
    func writeStream(_ matrixRaw: [[Double]]) {
        guard (rawFile != nil) && (filteredFile != nil) else {
            try? BoardShim.logMessage(.LEVEL_ERROR, "data files are not open")
            return
        }
        
        let raw = rawFile!
        let filtered = filteredFile!
        
        do {
            let numSamples = matrixRaw[0].count
            let pkgIDs = matrixRaw[pkgIDchannel]
            let timestamps = matrixRaw[timestampChannel]
            let markers = matrixRaw[markerChannel]
            var rawSamples = [[Double]]()
            var filteredSamples = [[Double]]()
            for channel in eegChannels {
                let ch = Int(channel)
                var filtered = matrixRaw[ch].map { $0 / 24.0 }
                try DataFilter.removeEnvironmentalNoise(data: &filtered, samplingRate: samplingRate, noiseType: NoiseTypes.SIXTY)
                var rawSample = [Double]()
                var filteredSample = [Double]()
                for iSample in 0..<numSamples {
                    rawSample.append(matrixRaw[ch][iSample])
                    filteredSample.append(filtered[iSample])
                }
                rawSamples.append(rawSample)
                filteredSamples.append(filteredSample)
            }
            
            raw.writeEEGsamples(pkgIDs: pkgIDs, timestamps: timestamps, markers: markers, samples: rawSamples)
            filtered.writeEEGsamples(pkgIDs: pkgIDs, timestamps: timestamps, markers: markers, samples: filteredSamples)
        } catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (.LEVEL_ERROR, bfError.message)
            try? BoardShim.logMessage (.LEVEL_ERROR, "Error code: \(bfError.errorCode)")
        } catch {
            try? BoardShim.logMessage (.LEVEL_ERROR, "cannot stream EEG samples to data files.\nError: \(error)")
        }
    }
    
    func writeHeaders() {
        guard (rawFile != nil) && (filteredFile != nil) else {
            try? BoardShim.logMessage(.LEVEL_ERROR, "data files are not open")
            return
        }
        
        let raw = rawFile!
        let filtered = filteredFile!

        var headerStr = "PKG ID, Timestamp, Marker"
        for i in 0..<eegChannels.count {
            headerStr += ", Ch\(i+1)"
        }
        headerStr += "\n"
        
        raw.write(Data(headerStr.utf8))
        filtered.write(Data(headerStr.utf8))
    }
    
    func cleanup() {
        try? BoardShim.logMessage(.LEVEL_INFO, "Headset.cleanup() UUID: \(self.uuid) boardId: \(self.boardId)")
        self.isActive = false
        self.isStreaming = false

        if let theBoard = board {
            try? theBoard.stopStream()
            try? theBoard.releaseSession()
        }
        
        if let rFile = self.rawFile  { rFile.synchronizeFile() }
        if let fFile = self.filteredFile  { fFile.synchronizeFile() }
    }
    
    func streamEEG() {
        var pauseCount = 1
        var numEmptyBuffers = 0
        
        guard board != nil else {
            try? BoardShim.logMessage(.LEVEL_ERROR, "board is nil")
            return
        }
        
        let theBoard = board!
        
//        defer {
//            try? BoardShim.logMessage(.LEVEL_INFO, "streaming EEG deferred exit")
//            cleanup()
//        }
        
        do {
            try theBoard.startStream()
            writeHeaders()
            try? BoardShim.logMessage(.LEVEL_INFO, "streaming EEG from headset")

            while true {
                guard self.isActive else {
                    try? BoardShim.logMessage(.LEVEL_INFO, "streaming EEG deactivated")
                    return
                }
                
                let matrixRaw = try theBoard.getBoardData()
                guard matrixRaw.count > 0 else {
                    numEmptyBuffers += 1
                    if numEmptyBuffers > 100 {
                        try? BoardShim.logMessage(.LEVEL_ERROR, "lost contact with headset")
                        self.isActive = false
                        return
                    }
                    if (numEmptyBuffers % 20) == 0 {
                        try? BoardShim.logMessage(.LEVEL_WARN, "empty buffers: \(numEmptyBuffers)") }
                    
                    usleep(1000)
                    continue
                }

                numEmptyBuffers = 0
                
                guard self.isStreaming else {
                    pauseCount += 1
                    continue
                }
                
                if pauseCount > 0 {
                    openNewFiles()
                }
                
                pauseCount = 0
                writeStream(matrixRaw)
            }
        }
        catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (.LEVEL_ERROR, bfError.message)
            try? BoardShim.logMessage (.LEVEL_ERROR, "Error code: \(bfError.errorCode)")
        }
        catch {
            try? BoardShim.logMessage (.LEVEL_ERROR, "undefined exception")
        }

        try? BoardShim.logMessage(.LEVEL_INFO, "streamEEG is terminating")
        cleanup()
    }
    
    static func scan(_ boardId: BoardIds) -> String {
        // Return the first device name matching "cu.usbserial-DM*"
        let fm = FileManager.default
        let prefix = "/dev"
        try? BoardShim.logMessage(.LEVEL_INFO, "Scanning for devices")

        do {
            let items = try fm.contentsOfDirectory(atPath: prefix)

            var deviceString: String = ""
            if cytons.contains(boardId) {
                deviceString = "cu.usbserial-DM" }
            else {
                deviceString = "cu.usbmodem"
            }

            for item in items.filter({$0.contains(deviceString)}) {
                try? BoardShim.logMessage(.LEVEL_INFO, "Found device \(item)")
                return prefix + "/" + item
            }
            
            try? BoardShim.logMessage(.LEVEL_ERROR, "Cannot find any matching devices")
            return ""
        } catch {
            try? BoardShim.logMessage(.LEVEL_ERROR, "Cannot list contents of /dev")
            return ""
        }
    }

}
