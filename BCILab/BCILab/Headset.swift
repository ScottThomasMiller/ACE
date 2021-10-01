//
//  Headset.swift
//
//  Created by Scott Miller for Aeris Rising, LLC on 8/27/21.
//

import Foundation
import SwiftUI


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

class Headset: ObservableObject {
    var isStreaming: Bool = false
    //let params = BrainFlowInputParams(serial_port: "/dev/cu.usbserial-DM0258EJ")
    let params = BrainFlowInputParams(serial_port: Headset.scan())
    private var rawFile: FileHandle
    private var filteredFile: FileHandle
    let boardId: BoardIds
    let board: BoardShim
    let samplingRate: Int32
    let eegChannels: [Int32]
    let boardDescription: BoardDescription
    let pkgIDchannel: Int
    let timestampChannel: Int
    let markerChannel: Int

    init(boardId: BoardIds) throws {
        self.boardId = boardId
        let fileID = CSVFile.uniqueID()
        rawFile = CSVFile(fileName: "BrainWave-EEG-Raw").openFile(id: fileID)
        filteredFile = CSVFile(fileName: "BrainWave-EEG-Filtered").openFile(id: fileID)
        
        do {
            try? BoardShim.logMessage(.LEVEL_INFO, "init headset: \(boardId)")
            board = try BoardShim(boardId, params)
            boardDescription = try BoardShim.getBoardDescr(boardId)
            samplingRate = try BoardShim.getSamplingRate(boardId)
            eegChannels = try BoardShim.getEEGchannels(boardId)
            markerChannel = try Int(BoardShim.getMarkerChannel(boardId))
            pkgIDchannel = try Int(BoardShim.getPackageNumChannel(boardId))
            timestampChannel = try Int(BoardShim.getTimestampChannel(boardId))
            
            try BoardShim.enableDevBoardLogger()
            try board.prepareSession()
            while try !board.isPrepared() {
                try? BoardShim.logMessage(.LEVEL_INFO, "waiting for session...")
                sleep(3)
            }
             
            try? BoardShim.logMessage(.LEVEL_INFO, "setting gain to 1")
            if !setGain(setting: .x1) {
                exit(-1)
            }
            
            if !setNumChannels() {
                exit(-1)
            }
            
            DispatchQueue.global(qos: .background).async {
                self.streamEEG()
            }            
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
    
    func reconnect() -> Bool {
        do {
            try self.board.releaseSession()
            try self.board.prepareSession()
            
            return try self.board.isPrepared()
        } catch let bfError as BrainFlowException {
            try? BoardShim.logMessage(.LEVEL_ERROR, bfError.message)
        } catch {
            try? BoardShim.logMessage(.LEVEL_ERROR, "\(error)")
        }
        
        return false
    }
    
    deinit {
        try? BoardShim.logMessage(.LEVEL_INFO, "Headset.deinit()")
        try? board.releaseSession()
    }

    func setGain(setting: GainSettings) -> Bool {
        var i = 0
        for channel in ChannelIDs.allCases {
            if i >= eegChannels.count {
                continue
            }
            i += 1
            let command = "x" + channel.rawValue + setting.rawValue + "0110X"
            let expected = "Success: Channel set for \(i)$$$"
            do {
                let response = try board.configBoard(command)
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
        // send "c" for Cyton or "C" for Cyton+Daisy
        var command: String = ""
        if boardId == .CYTON_BOARD {
            command = "c" }
        else if boardId == .CYTON_DAISY_BOARD {
            command = "C"
        }
        print("setNumChannels sending: \(command)")
        
        guard let response = try? board.configBoard(command) else {
            print("Error.  Cannot send command.")
            return false
        }
        
        print("response: \(response)")
        return true
    }

    func reopenFiles()  {
        try? rawFile.close()
        try? filteredFile.close()
        let uqID = CSVFile.uniqueID()
        rawFile = CSVFile(fileName: "BrainWave-EEG-Raw").openFile(id: uqID)
        filteredFile = CSVFile(fileName: "BrainWave-EEG-Filtered").openFile(id: uqID)
    }
    
    func writeStream(_ matrixRaw: [[Double]]) {
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
                try DataFilter.performBandpass(data: &filtered, samplingRate: samplingRate, centerFreq: 27.5, bandWidth: 45.0, order: 4, filterType: FilterTypes.BUTTERWORTH, ripple: 1.0)
                var rawSample = [Double]()
                var filteredSample = [Double]()
                for iSample in 0..<numSamples {
                    rawSample.append(matrixRaw[ch][iSample])
                    filteredSample.append(filtered[iSample])
                }
                rawSamples.append(rawSample)
                filteredSamples.append(filteredSample)
            }
            
            rawFile.writeEEGsamples(pkgIDs: pkgIDs, timestamps: timestamps, markers: markers, samples: rawSamples)
            filteredFile.writeEEGsamples(pkgIDs: pkgIDs, timestamps: timestamps, markers: markers, samples: filteredSamples)
        } catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (.LEVEL_ERROR, bfError.message)
            try? BoardShim.logMessage (.LEVEL_ERROR, "Error code: \(bfError.errorCode)")
        } catch {
            try? BoardShim.logMessage (.LEVEL_ERROR, "undefined exception")
        }
    }
    
    func writeHeaders() {
        var headerStr = "PKG ID, Timestamp, Marker"
        for i in 0..<eegChannels.count {
            headerStr += ", Ch\(i+1)"
        }
        headerStr += "\n"
        rawFile.write(Data(headerStr.utf8))
        filteredFile.write(Data(headerStr.utf8))
    }
    
    func streamEEG() {
        var pauseCount = 0
        
        defer {
            self.isStreaming = false
            try? BoardShim.logMessage(.LEVEL_INFO, "Headset.streamEEG.defer")
            try? board.isPrepared() ? try? board.releaseSession() :
                                      try?  BoardShim.logMessage(.LEVEL_INFO, "defer: session already closed")
            rawFile.closeFile()
            filteredFile.closeFile()
        }
        
        do {
            try board.startStream()
            writeHeaders()
            try? BoardShim.logMessage(.LEVEL_INFO, "streaming EEG")

            while true {
                let matrixRaw = try board.getBoardData()
                guard matrixRaw.count > 0 else {
                    continue
                }

                guard self.isStreaming else {
                    pauseCount += 1
                    continue
                }
                
                if pauseCount > 0 {
                    reopenFiles()
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

    }
    
    static func scan() -> String {
        // Return the first device name matching "cu.usbserial-DM*"
        let fm = FileManager.default
        let prefix = "/dev"
        try? BoardShim.logMessage(.LEVEL_INFO, "Scanning for devices")

        do {
            let items = try fm.contentsOfDirectory(atPath: prefix)

            for item in items.filter({$0.contains("cu.usbserial-DM")}) {
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
