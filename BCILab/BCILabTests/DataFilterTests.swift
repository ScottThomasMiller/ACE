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
            let boardDescription = try BoardShim.getBoardDescr(boardId)
            let samplingRate = boardDescription.sampling_rate
            let board = try BoardShim(boardId, params)
            try board.prepareSession()
            try board.startStream()
            try BoardShim.logMessage(logLevel: .LEVEL_INFO, message: "start sleeping in the main thread")
            sleep(5)
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
            let samplingRate = try BoardShim.getSamplingRate(boardId)
            let board = try BoardShim(boardId, params)
            try board.prepareSession()
            try board.startStream()
            try BoardShim.logMessage(logLevel: .LEVEL_INFO, message: "start sleeping in the main thread")
            sleep(5)
            let data = try board.getBoardData()
            try board.stopStream()
            try board.releaseSession()

            let EEGchannels = try BoardShim.getEEGchannels(boardId)
            let bands = try DataFilter.getAvgBandPowers(data: data, channels: EEGchannels,
                                                        samplingRate: samplingRate, applyFilters: true)
            
            let avgSum = bands.0.reduce(0, +)
            let stdSum = bands.1.reduce(0, +)
            XCTAssert((bands.0.count == 5) && (bands.1.count == 5) &&
                      (avgSum > 0) && (avgSum <= 1) && (stdSum > 0) && (stdSum < 10))
        }
        catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: bfError.message)
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "Error code: \(bfError.errorCode)")
            }
        catch {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "undefined exception")
        }
    }
    
    func testCSP() {
        let labels: [Double] = [0.0, 1.0]
        let data: [[[Double]]] = [[[6, 3, 1, 5], [3, 0, 5, 1]], [[1, 5, 6, 2], [5, 1, 2, 2]]]
        let trueFilters: [[String]] = [["-0.313406", "0.079215"], ["-0.280803", "-0.480046"]]
        let trueEigVals: [String] = ["0.456713", "0.752979"]

        do {
            let (filters, eigVals) = try DataFilter.getCSP(data: data, labels: labels)
            
            let roundFilters = filters.map( { $0.map( {String(format: "%.6f", $0)}) } )
            let roundEigVals = eigVals.map( {String(format: "%.6f", $0)} )
            
            XCTAssert(roundFilters == trueFilters)
            XCTAssert(roundEigVals == trueEigVals)
        }
        catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: bfError.message)
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "Error code: \(bfError.errorCode)")
            }
        catch {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "undefined exception")
        }
    }
    
    func testDenoising() {
        // use synthetic board for demo
        let params = BrainFlowInputParams()
        let boardId = BoardIds.SYNTHETIC_BOARD
  
        do {
            let board = try BoardShim(boardId, params)
            try board.prepareSession()
            try board.startStream()
            try BoardShim.logMessage(logLevel: .LEVEL_INFO, message: "start sleeping in the main thread")
            sleep(5)
            var data = try board.getBoardData()
            try board.stopStream()
            try board.releaseSession()
            
            // demo how to convert it to pandas DF and plot data
            let EEGchannels = try BoardShim.getEEGchannels(boardId)

            // demo for denoising, apply different methods to different channels for demo
            for count in EEGchannels.indices {
                // first of all you can try simple moving median or moving average with different window size
                let channel = Int(EEGchannels[count])
                let num = Double(data[channel].compactMap{$0}.count)
                let beforeSum = Double(data[channel].compactMap( {$0} ).reduce(0, +))
                let beforeAvg = String(format: "%.1f", beforeSum / num)
                
                func compareBeforeAfter(_ data: [Double]) {
                    // averages are rounded to one decimal place before comparison
                    let afterSum = Double(data.compactMap{$0}.reduce(0, +))
                    let afterAvg = String(format: "%.1f", afterSum / num)
                    XCTAssert((beforeSum != afterSum) && (beforeAvg == afterAvg))
                }

                switch count {
                case 0:
                    try DataFilter.performRollingFilter(data: &data[channel], period: 3, operation: .MEAN)
                    compareBeforeAfter(data[channel])
                case 1:
                    try DataFilter.performRollingFilter(data: &data[channel], period: 3, operation: .MEDIAN)
                    compareBeforeAfter(data[channel])
                    // if methods above dont work for your signal you can try wavelet based denoising
                    // feel free to try different functions and decomposition levels
                case 2:
                    try DataFilter.performWaveletDenoising(data: &data[channel], wavelet: "db6", decompositionLevel: 3)
                    compareBeforeAfter(data[channel])
                case 3:
                    try DataFilter.performWaveletDenoising(data: &data[channel], wavelet: "bior3.9", decompositionLevel: 3)
                    compareBeforeAfter(data[channel])
                case 4:
                    try DataFilter.performWaveletDenoising(data: &data[channel], wavelet: "sym7", decompositionLevel: 3)
                    compareBeforeAfter(data[channel])
                case 5:
                    // with synthetic board this one looks like the best option, but it depends on many circumstances
                    try DataFilter.performWaveletDenoising(data: &data[channel], wavelet: "coif3", decompositionLevel: 3)
                    compareBeforeAfter(data[channel])
                default:
                    throw BrainFlowException("Invalid channel value: \(channel)", .EMPTY_BUFFER_ERROR)
                }
            }
        }
        catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: bfError.message)
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "Error code: \(bfError.errorCode)")
            }
        catch {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "undefined exception")
        }
    }
    
    func testDownsampling () {
        BoardShim.enableDevBoardLogger()
        // use synthetic board for demo
        let params = BrainFlowInputParams()
        let boardId = BoardIds.SYNTHETIC_BOARD

        do {
            // use synthetic board for demo
            let board = try BoardShim(boardId, params)
            try board.prepareSession()
            try board.startStream()
            try BoardShim.logMessage(logLevel: .LEVEL_INFO, message: "start sleeping in the main thread")
            sleep(5)
            let data = try board.getBoardData(20)
            try board.stopStream()
            try board.releaseSession()

            let EEGchannels = try BoardShim.getEEGchannels(.SYNTHETIC_BOARD)
            // demo for downsampling, it just aggregates data
            for count in EEGchannels.indices {
                let channel = Int(EEGchannels[count])
                let num = Double(data[channel].compactMap{$0}.count)
                let beforeSum = Double(data[channel].compactMap( {$0} ).reduce(0, +))
                let beforeAvg = String(format: "%.1f", beforeSum / num)
                
                func compareBeforeAfter(_ data: [Double]) {
                    // averages are rounded to one decimal place before comparison
                    let afterSum = Double(data.compactMap{$0}.reduce(0, +))
                    let afterAvg = String(format: "%.1f", afterSum / num)
                    XCTAssert((beforeSum != afterSum) && (beforeAvg != afterAvg))
                }

                switch count {
                case 0:
                    let downsampledData = try DataFilter.performDownsampling(data: data[channel], period: 3, operation: .MEDIAN)
                    compareBeforeAfter(downsampledData)
                case 1:
                    let downsampledData = try DataFilter.performDownsampling(data: data[channel], period: 2, operation: .MEAN)
                    compareBeforeAfter(downsampledData)
                default:
                    let downsampledData = try DataFilter.performDownsampling(data: data[channel], period: 2, operation: .EACH)
                    compareBeforeAfter(downsampledData)
                }
            }
        }
        catch let bfError as BrainFlowException {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: bfError.message)
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "Error code: \(bfError.errorCode)")
            }
        catch {
            try? BoardShim.logMessage (logLevel: .LEVEL_ERROR, message: "undefined exception")
        }

    }
}
