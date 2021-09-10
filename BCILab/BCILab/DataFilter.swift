//
//  DataFilter.swift
//  A binding for BrainFlow's data_filter high-level API
//
//  Created by Scott Miller for Aeris Rising, LLC on 8/27/21.
//


import Foundation

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
    static func performDownsampling (data: inout [Double], period: Int32, operation: Int32) throws -> [Double] {
        if (period <= 0) {
            throw BrainFlowException("Invalid period", .INVALID_ARGUMENTS_ERROR)
        }
        
        let dataLen = Int32(data.count)
        let newSize = dataLen / period
        
        if (newSize <= 0) {
            throw BrainFlowException ("Invalid data size", .INVALID_ARGUMENTS_ERROR)
        }
        
        var downsampledData = [Double](repeating: 0.0, count: Int(newSize))
        let errorCode = perform_downsampling (&data, dataLen, period, operation, &downsampledData)
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

}
