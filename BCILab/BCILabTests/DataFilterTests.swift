//
//  DataFilterTests.swift
//  These are the unit tests for DataFilter.swift.  They are modeled after
//  https://github.com/brainflow-dev/brainflow/tree/master/tests/python

import XCTest
@testable import BCILab

class DataFilterTests: XCTestCase {
    
    func testBandPower() {
        BoardShim.enableDevBoardLogger()

        // use synthetic board for demo
        do {
            let params = BrainFlowInputParams()
            let boardId = BoardIds.SYNTHETIC_BOARD
            let boardDescription = try BoardShim.getBoardDescr(boardId: boardId)
            let samplingRate = boardDescription.sampling_rate
            let board = try BoardShim(boardId, params)
            try board.prepareSession()
            try board.startStream()
            try BoardShim.logMessage(logLevel: .LEVEL_INFO, message: "start sleeping in the main thread")
            sleep(10)
            let nfft = try DataFilter.getNearestPowerOfTwo(value: samplingRate)
            var data = try board.getBoardData()
            try board.stopStream()
            try board.releaseSession()

            let EEGchannels = boardDescription.eeg_channels
            // second eeg channel of synthetic board is a sine wave at 10Hz, should see huge alpha
            let eegChannel = Int(EEGchannels[1])
            // optional detrend
            try DataFilter.deTrend(data: &data[eegChannel], operation: .LINEAR)
            
            let overlap = Int32(floor(Double(Int(nfft) / 2)))
            let psd = try DataFilter.getPSDwelch(data: data[eegChannel], nfft: nfft,
                                             overlap: overlap, samplingRate: samplingRate,
                                             window: .BLACKMAN_HARRIS)

            let bandPowerAlpha = try DataFilter.getBandPower(psd: psd, freqStart: 7.0, freqEnd: 13.0)
            let bandPowerBeta = try DataFilter.getBandPower(psd: psd, freqStart: 14.0, freqEnd: 30.0)
            print("alpha/beta:\(bandPowerAlpha / bandPowerBeta)")

            // fail test if ratio is not smth we expect
            XCTAssert((bandPowerAlpha / bandPowerBeta) >= 100.0) }
        catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: bfError.message)
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "Error code: \(bfError.errorCode)")
            }
        catch {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "undefined exception")
        }
    }
    
    func testBandPowerAll() {
        BoardShim.enableDevBoardLogger()

        // use synthetic board for demo
        let params = BrainFlowInputParams()
        let boardId = BoardIds.SYNTHETIC_BOARD
        do {
            let samplingRate = try BoardShim.getSamplingRate(boardId: boardId)
            let board = try BoardShim(boardId, params)
            try board.prepareSession()
            try board.startStream()
            try BoardShim.logMessage(logLevel: .LEVEL_INFO, message: "start sleeping in the main thread")
            sleep(10)
            let data = try board.getBoardData()
            try board.stopStream()
            try board.releaseSession()

            let EEGchannels = try BoardShim.getEEGchannels(boardId: boardId)
            let bands = try DataFilter.getAvgBandPowers(data: data, channels: EEGchannels, samplingRate:
                                                        samplingRate, applyFilters: true)
            print("avg band powers : \(bands.0)")
            print("stddev band powers : \(bands.1)") }
        catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: bfError.message)
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "Error code: \(bfError.errorCode)")
            }
        catch {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "undefined exception")
        }
    }
}
