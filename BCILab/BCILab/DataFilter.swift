//
//  DataFilter.swift
//  A binding for BrainFlow's data_filter high-level API
//
//  Created by Scott Miller for Aeris Rising, LLC on 8/27/21.
//


import Foundation
import Numerics
    
struct DataFilter {
    /**
     * enable Data logger with level INFO
     */
    func enableDataLogger () throws {
        do {
            try setLogLevel (.LEVEL_INFO) }
        catch {
            throw error
        }
    }

    /**
     * enable Data logger with level TRACE
     */
    func enableDevDataLogger () throws {
        do {
            try setLogLevel (.LEVEL_TRACE) }
        catch {
            throw error
        }
    }

    /**
     * disable Data logger
     */
    func disableDataLogger () throws {
        do {
            try setLogLevel (.LEVEL_OFF) }
        catch {
            throw error
        }
    }

    /**
     * redirect logger from stderr to a file
     */
    func setLogFile (_ logFile: String) throws {
        var cLogFile = logFile.cString(using: String.Encoding.utf8)!
        let errorCode = set_log_file (&cLogFile)
        try checkErrorCode("Error in set_log_file", errorCode)
    }

    /**
     * set log level
     */
    private func setLogLevel (_ logLevel: LogLevels) throws {
        let errorCode = set_log_level (logLevel.rawValue)
        try checkErrorCode("Error in set_log_level", errorCode)
    }

    /**
    * perform lowpass filter in-place
    */
    func performLowpass (data: inout [Double], samplingRate: Int32, cutoff: Double,
                         order: Int32, filterType: FilterTypes, ripple: Double) throws {
        let dataLen = Int32(data.count)
        let filterVal = filterType.rawValue
        let errorCode = perform_lowpass (&data, dataLen, samplingRate, cutoff, order, filterVal, ripple)
        try checkErrorCode("Failed to apply filter", errorCode)
    }

    /**
    * perform highpass filter in-place
    */
    func performHighpass (data: inout [Double], samplingRate: Int32, cutoff: Double,
                         order: Int32, filterType: FilterTypes, ripple: Double) throws {
        let dataLen = Int32(data.count)
        let filterVal = filterType.rawValue
        let errorCode = perform_highpass (&data, dataLen, samplingRate, cutoff, order, filterVal, ripple)
        try checkErrorCode("Failed to apply filter", errorCode)
    }

    /**
     * perform bandpass filter in-place
     */
    func performBandpass (data: inout [Double], samplingRate: Int32, centerFreq: Double, bandWidth: Double,
                          order: Int32, filterType: FilterTypes, ripple: Double) throws {
        let dataLen = Int32(data.count)
        let filterVal = filterType.rawValue
        let errorCode = perform_bandpass (&data, dataLen, samplingRate, centerFreq, bandWidth, order,
                                       filterVal, ripple)
        try checkErrorCode("Failed to apply filter", errorCode)
    }

    /**
     * perform bandstop filter in-place
     */
    func performBandstop (data: inout [Double], samplingRate: Int32, centerFreq: Double, bandWidth: Double,
                          order: Int32, filterType: FilterTypes, ripple: Double) throws {
        let dataLen = Int32(data.count)
        let filterVal = filterType.rawValue
        let errorCode = perform_bandstop (&data, dataLen, samplingRate, centerFreq, bandWidth, order,
                                       filterVal, ripple)
        try checkErrorCode("Failed to apply filter", errorCode)
    }
    
    /**
     * perform moving average or moving median filter in-place
     */
    func performRollingFilter (data: inout [Double], period: Int32, operation: Int32) throws {
        let dataLen = Int32(data.count)
        let errorCode = perform_rolling_filter (&data, dataLen, period, operation)
        try checkErrorCode("Failed to apply filter", errorCode)
    }
    
    /**
     * subtract trend from data in-place
     */
    func deTrend (data: inout [Double], operation: Int32) throws {
        let dataLen = Int32(data.count)
        let errorCode = detrend (&data, dataLen, operation)
        try checkErrorCode("Failed to detrend", errorCode)
    }
    
    /**
     * perform data downsampling, it doesnt apply lowpass filter for you, it just
     * aggregates several data points
     */
    static func performDownsampling (data: [Double], period: Int32, operation: Int32) throws -> [Double] {
        guard (period > 0) else {
            throw BrainFlowException("Invalid period", .INVALID_ARGUMENTS_ERROR)
        }
        
        let dataLen = Int32(data.count)
        let newSize = dataLen / period
        
        if (newSize <= 0) {
            throw BrainFlowException ("Invalid data size", .INVALID_ARGUMENTS_ERROR)
        }
        
        var downsampledData = [Double](repeating: 0.0, count: Int(newSize))
        var cData = data
        let errorCode = perform_downsampling (&cData, dataLen, period, operation, &downsampledData)
        try checkErrorCode("Failed to perform downsampling", errorCode)

        return downsampledData
    }
    
    /**
     * removes noise using notch filter
     */
    func removeEnvironmentalNoise (data: inout [Double], samplingRate: Int32, noiseType: NoiseTypes) throws {
        let dataLen = Int32(data.count)
        let errorCode = remove_environmental_noise (&data, dataLen, samplingRate, noiseType.rawValue)
        try checkErrorCode("Failed to remove noise", errorCode)
    }

    /**
     * perform wavelet based denoising in-place
     *
     * @param wavelet             supported vals:
     *    db1..db15,haar,sym2..sym10,coif1..coif5,bior1.1,bior1.3,bior1.5,bior2.2,bior2.4,bior2.6,bior2.8,bior3.1,bior3.3,bior3.5,
     *    bior3.7,bior3.9,bior4.4,bior5.5,bior6.8
     *
     * @param decomposition_level level of decomposition of wavelet transform
     */
    func performWaveletDenoising (data: inout [Double], wavelet: String, decompositionLevel: Int32) throws {
        let dataLen = Int32(data.count)
        var cWavelet = wavelet.cString(using: String.Encoding.utf8)!
        let errorCode = perform_wavelet_denoising (&data, dataLen, &cWavelet, decompositionLevel)
        try checkErrorCode("Failed to perform denoising", errorCode)
    }
    
    /**
     * perform wavelet transform
     *
     * @param wavelet supported vals:
     *                db1..db15,haar,sym2..sym10,coif1..coif5,bior1.1,bior1.3,bior1.5,bior2.2,bior2.4,bior2.6,bior2.8,bior3.1,bior3.3,bior3.5
     *                ,bior3.7,bior3.9,bior4.4,bior5.5,bior6.8
     */
    static func performWaveletTransform(data: [Double], wavelet: String, decompositionLevel: Int32) throws -> ([Double], [Int32]) {
        guard (decompositionLevel > 0) else {
            throw BrainFlowException ("Invalid decomposition level", .INVALID_ARGUMENTS_ERROR)
        }
        
        let dataLen = Int32(data.count)
        var cWavelet = wavelet.cString(using: String.Encoding.utf8)!
        var lengths = [Int32](repeating: 0, count: Int(decompositionLevel) + 1)
        let outputLen = dataLen + 2 * decompositionLevel * (40 + 1)
        var outputArray = [Double](repeating: 0.0, count: Int(outputLen))
        
        var cData = data
        let errorCode = perform_wavelet_transform (&cData, dataLen, &cWavelet, decompositionLevel,
                                                   &outputArray, &lengths)
        try checkErrorCode("Failed to perform wavelet transform", errorCode)

        let totalLen = Int(lengths.reduce(0, +))
        let result = Array(outputArray[..<totalLen])
        
        return (result, lengths)
    }
    
    /**
      * perform inverse wavelet transform
      */
    static func performInverseWaveletTransform (waveletTuple: ([Double], [Int32]), originalDataLen: Int32,
                                                wavelet: String, decompositionLevel: Int32) throws -> [Double] {
        guard (decompositionLevel > 0) else {
            throw BrainFlowException ("Invalid decomposition level", .INVALID_ARGUMENTS_ERROR)
        }
        
        var outputArray = [Double](repeating: 0.0, count: Int(originalDataLen))
        var waveletCoeffs = waveletTuple.0
        var decompositionLengths = waveletTuple.1
        var cWavelet = wavelet.cString(using: String.Encoding.utf8)!

        let errorCode = perform_inverse_wavelet_transform (&waveletCoeffs, originalDataLen, &cWavelet,
                                                           decompositionLevel, &decompositionLengths,
                                                           &outputArray)
        try checkErrorCode("Failed to perform inverse wavelet transform", errorCode)

        return outputArray
     }
    
    /**
     * get common spatial filters
     */
    static func getCsp (data: [[[Double]]], labels: inout [Double]) throws -> ([[Double]], [Double]) {
        let nEpochs = data.count
        let nChannels = data[0].count
        let nTimes = data[0][0].count

        var tempData1d = [Double](repeating: 0.0, count: Int(nEpochs * nChannels * nTimes))
        for e in 0..<nEpochs {
            for c in 0..<nChannels {
                for t in 0..<nTimes {
                    let idx = e * nChannels * nTimes + c * nTimes + t
                    tempData1d[idx] = data[e][c][t]
                }
            }
        }

        var tempFilters = [Double](repeating: 0.0, count: nChannels * nChannels)
        var outputEigenvalues = [Double](repeating: 0.0, count: nChannels)

        let errorCode = get_csp (&tempData1d, &labels, Int32(nEpochs), Int32(nChannels), Int32(nTimes),
                                 &tempFilters, &outputEigenvalues)
        try checkErrorCode("Failed to get the CSP filters", errorCode)

        var outputFilters = [[Double]](repeating: [Double](repeating: 0.0, count: nChannels), count: nChannels)
        for i in 0..<nChannels {
            for j in 0..<nChannels {
                outputFilters[i][j] = tempFilters[i * nChannels + j]
            }
        }

        return (outputFilters, outputEigenvalues)
    }
    
    /**
     * perform data windowing
     *
     * @param window     window function
     * @param window_len lenght of the window function
     * @return array of the size specified in window_len
     */
    static func getWindow (window: Int32, windowLen: Int32) throws -> [Double] {
        var windowData = [Double](repeating: 0.0, count: Int(windowLen))
        let errorCode = get_window (window, windowLen, &windowData)
        try checkErrorCode("Failed to perform windowing", errorCode)

        return windowData
    }

    /**
     * perform direct fft
     *
     * @param data      data for fft transform
     * @param start_pos starting position to calc fft
     * @param end_pos   end position to calc fft, total_len must be a power of two
     * @param window    window function
     * @return array of complex values with size N / 2 + 1
     */
    static func performFFT (data: [Double], startPos: Int32, endPos: Int32, window: Int32) throws -> [Complex<Double>] {
        let dataLen = data.count
        guard (startPos >= 0) && (endPos <= dataLen) && (startPos < endPos) else {
            throw BrainFlowException ("invalid position arguments", .INVALID_ARGUMENTS_ERROR)
        }
        
        // I didnt find a way to pass an offset using pointers, copy array
        var dataToProcess = Array(data[Int(startPos)..<Int(endPos)])
        let len = dataToProcess.count
        
        guard ((len & (len - 1)) == 0) else {
            throw BrainFlowException ("end_pos - start_pos must be a power of 2", .INVALID_ARGUMENTS_ERROR)
        }
        
        var complexReal = [Double](repeating: 0.0, count: (len / 2 + 1))
        var complexImaginary = [Double](repeating: 0.0, count: (len / 2 + 1))
        let errorCode = perform_fft (&dataToProcess, Int32(len), window, &complexReal, &complexImaginary)
        try checkErrorCode("Failed to perform fft", errorCode)

        let complexResult = zip(complexReal, complexImaginary).map{Complex<Double>($0, $1)}
        return complexResult
    }

    /**
     * perform inverse fft
     *
     * @param data data from fft transform(array of complex values)
     * @return restored data
     */
    static func performIFFT (data: [Complex<Double>]) throws -> [Double]
    {
        var complexReal = data.map{$0.real}
        var complexImaginary = data.map{$0.imaginary}
        
        let len = (data.count - 1) * 2
        var output = [Double](repeating: 0.0, count: len)
        let errorCode = perform_ifft (&complexReal, &complexImaginary, Int32(len), &output)
        try checkErrorCode("Failed to perform ifft", errorCode)

        return output
    }
    
    /**
         * calc average and stddev of band powers across all channels, bands are
         * 1-4,4-8,8-13,13-30,30-50
         *
         * @param data          data to process
         * @param channels      rows of data arrays which should be used in calculation
         * @param sampling_rate sampling rate
         * @param apply_filters apply bandpass and bandstop filters before calculation
         * @return pair of avgs and stddevs for bandpowers
         */
    static func getAvgBandPowers (data: [[Double]]?, channels: [Int32]?, samplingRate: Int32,
                                  applyFilters: Bool) throws -> ([Double], [Double]) {
        guard ((data != nil) && (channels != nil)) else {
            throw BrainFlowException ("data or channels null", .INVALID_ARGUMENTS_ERROR)
        }

        // convert channels from [Int32]? to [Int] for syntactic sugar:
        let iChannels = channels!.map{Int($0)}
        
        var data1d = [Double](repeating: 0.0, count: iChannels.count * data![iChannels[0]].count)
        for i in 0..<iChannels.count {
            let ch = iChannels[i]
            for j in 0..<data![ch].count {
                data1d[j + i * data![iChannels[i]].count] = data![iChannels[i]][j]
            }
        }

        var avgs = [Double](repeating: 0.0, count: 5)
        var stddevs = [Double](repeating: 0.0, count: 5)
        let filtersOn = Int32(applyFilters ? 1 : 0)
        let numRows = Int32(iChannels.count)
        let numCols = Int32(data![iChannels[0]].count)

        let errorCode = get_avg_band_powers (&data1d, numRows, numCols, samplingRate,
                                             filtersOn, &avgs, &stddevs)
        try checkErrorCode("Failed to get_avg_band_powers", errorCode)

        return (avgs, stddevs)
    }
    
    /**
      * get PSD
      *
      * @param data          data to process
      * @param start_pos     starting position to calc PSD
      * @param end_pos       end position to calc PSD, total_len must be a power of
      *                      two
      * @param sampling_rate sampling rate
      * @param window        window function
      * @return pair of ampl and freq arrays with len N / 2 + 1
      */
    static func getPSD (data: [Double], startPos: Int32, endPos: Int32, samplingRate: Int32, window: Int32) throws -> ([Double], [Double]) {
         guard ((startPos >= 0) && (endPos <= data.count) && (startPos < endPos)) else {
             throw BrainFlowException ("invalid position arguments", .INVALID_ARGUMENTS_ERROR)
         }
        
        // I didnt find a way to pass an offset using pointers, copy array
        var dataToProcess = Array(data[Int(startPos)..<Int(endPos)])
        let len = dataToProcess.count
        guard ((len & (len - 1)) == 0) else {
             throw BrainFlowException ("end_pos - start_pos must be a power of 2", .INVALID_ARGUMENTS_ERROR)
        }
        
        var ampls = [Double](repeating: 0.0, count: len / 2 + 1)
        var freqs = [Double](repeating: 0.0, count: len / 2 + 1)
        let errorCode = get_psd (&dataToProcess, Int32(len), samplingRate, window, &ampls, &freqs)
        try checkErrorCode("Failed to psd", errorCode)

        return (ampls, freqs)
     }
}
