//
//  Headset.swift
//  BrainBook
//
//  Created by Scott Miller on 8/27/21.
//

import Foundation

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

class Headset {
    var isReady: Bool = false
    let params = BrainFlowInputParams(serial_port: "/dev/cu.usbserial-DM0258EJ")
    let boardId: BoardIds
    let board: BoardShim
    let samplingRate: Int32
    let eegChannels: [Int32]
    let boardDescJSON: String
    let boardDescDict: [String: Any]
    let pkgIDchannel: Int
    let timestampChannel: Int
    let markerChannel: Int

    init(boardId: BoardIds) throws {
        self.boardId = boardId
        do {
            print("setup headset")
            board = try BoardShim(boardId, params)
            boardDescJSON = try getBoardDescr(boardId: boardId)
            boardDescDict = boardDescJSON.convertToDictionary()!
            samplingRate = try getSamplingRate(boardId: boardId)
            eegChannels = try getEEGchannels(boardId: boardId)
            markerChannel = try Int(getMarkerChannel(boardId: boardId))
            pkgIDchannel = try Int(getPackageNumChannel(boardId: boardId))
            timestampChannel = try Int(getTimestampChannel(boardId: boardId))
            
            print("board description:\n\(boardDescJSON)")
            print("preparing session")
            
            try board.prepareSession()
            while try !board.isPrepared() {
                print("waiting for session...")
                sleep(3)
            }
            
            print("setting gain to x1")
            if !setGain(setting: .x1) {
                exit(-1)
            }
            
            if !setNumChannels() {
                exit(-1)
            }
        }
        catch {
            try? logMessage (logLevel: LogLevels.LEVEL_ERROR.rawValue, message: "Failed to initialize headset")
            try? logMessage (logLevel: LogLevels.LEVEL_ERROR.rawValue, message: error.localizedDescription)
            throw error
        }
        enableDevBoardLogger()
        isReady = true
    }
    
    deinit {
        try? board.isPrepared() ? try? board.releaseSession() : print("deinit: session already closed")
    }

    func setGain(setting: GainSettings) -> Bool {
        var i = 0
        for channel in ChannelIDs.allCases {
            if i >= eegChannels.count {
                continue
            }
            i += 1
            let command = "x" + channel.rawValue + setting.rawValue + "0110X"
            do {
                let response = try board.configBoard(command)
                print("set \(channel) to gain value \(setting) with command \(command)")
                print("reponse: \(response)")
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
        else {
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
    
    func streamEEG() {
        let filter = DataFilter()
        let rawFile = CSVFile(fileName: "BrainWave-EEG-Raw").openFile()
        let filteredFile = CSVFile(fileName: "BrainWave-EEG-Filtered").openFile()
        
        defer {
            try? board.isPrepared() ? try? board.releaseSession() : print("defer: session already closed")
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

        do {
            //try setLogFile("brainflow.csv")
            //try board.startStream(bufferSize: 10000000, streamerParams: "file://%file_name%:w")
            try board.startStream()
            writeHeaders()
            print("streaming EEG")

            while true {
                let matrixRaw = try board.getBoardData()
                guard matrixRaw.count > 0 else {
                    continue
                }
                let numSamples = matrixRaw[0].count
                let pkgIDs = matrixRaw[pkgIDchannel]
                let timestamps = matrixRaw[timestampChannel]
                let markers = matrixRaw[markerChannel]
                var rawSamples = [[Double]]()
                var filteredSamples = [[Double]]()
                for channel in eegChannels {
                    let ch = Int(channel)
                    var filtered = matrixRaw[ch].map { $0 / 24.0 }
                    try filter.removeEnvironmentalNoise(data: &filtered, samplingRate: samplingRate, noiseType: NoiseTypes.SIXTY)
                    try filter.performBandpass(data: &filtered, samplingRate: samplingRate, centerFreq: 27.5, bandWidth: 45.0, order: 4, filterType: FilterTypes.BUTTERWORTH, ripple: 1.0)
                    var rawSample = [Double]()
                    var filteredSample = [Double]()
                    for iSample in 0..<numSamples {
                        rawSample.append(matrixRaw[ch][iSample])
                        filteredSample.append(filtered[iSample])
                    }
                    rawSamples.append(rawSample)
                    filteredSamples.append(filteredSample)
                }
                rawFile.writeSamples(pkgIDs: pkgIDs, timestamps: timestamps, markers: markers, samples: rawSamples)
                filteredFile.writeSamples(pkgIDs: pkgIDs, timestamps: timestamps, markers: markers, samples: filteredSamples)
                sleep(2)
            }
        }
        catch let bfError as BrainFlowException {
            try? logMessage (logLevel: LogLevels.LEVEL_ERROR.rawValue, message: bfError.message)
            try? logMessage (logLevel: LogLevels.LEVEL_ERROR.rawValue, message: "Error code: \(bfError.errorCode)") }
        catch {
            try? logMessage (logLevel: LogLevels.LEVEL_ERROR.rawValue, message: "undefined exception")
        }
    }

}
