//
//  BoardShim.swift
//  A binding for BrainFlow's board_shim high-level API
//
//  Created by Scott Miller for Aeris Rising, LLC on 8/23/21.
//

import Foundation

/////////////////////////////////////////
//////////// logging methods ////////////
/////////////////////////////////////////

func enableBoardLogger () {
    set_log_level (LogLevels.LEVEL_INFO.rawValue)
}

func disableBoardLogger () {
    set_log_level (LogLevels.LEVEL_OFF.rawValue)
}

func enableDevBoardLogger () {
    set_log_level (LogLevels.LEVEL_TRACE.rawValue)
}

func setLogFile (_ logFile: String) throws
{
    var cLogFile = logFile.cString(using: String.Encoding.utf8)!
    let result = set_log_file(&cLogFile)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException("failed to set log file", result)
    }
}

func setLogLevel (_ logLevel: LogLevels) throws
{
    let result = set_log_level (logLevel.rawValue)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("failed to set log level", result)
    }
}

/**
 * send user defined strings to BrainFlow logger
 */
func logMessage (logLevel: Int32, message: String) throws {
    var cMessage = message.cString(using: String.Encoding.utf8)!
    let result = log_message (logLevel, &cMessage)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("Error in log_message", result)
    }
}

/**
 * get sampling rate for this board
 */
func getSamplingRate (boardId: BoardIds) throws -> Int32 {
    var samplingRate: Int32 = 0
    let result = get_sampling_rate (boardId.rawValue, &samplingRate)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("Error in board info getter", result)
    }
    return samplingRate
}

/**
 * get row index in returned by get_board_data() 2d array which contains timestamps
 */
func getTimestampChannel (boardId: BoardIds) throws -> Int32 {
    var timestampChannel: Int32 = 0
    let result = get_timestamp_channel (boardId.rawValue, &timestampChannel)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("Error in board info getter", result)
    }
    return timestampChannel
}

/**
 * get row index in returned by get_board_data() 2d array which contains markers
 */
func getMarkerChannel (boardId: BoardIds) throws -> Int32
{
    var markerChannel: Int32 = 0
    let result = get_marker_channel (boardId.rawValue, &markerChannel)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("Error in board info getter", result)
    }
    return markerChannel
}

/**
 * get number of rows in returned by get_board_data() 2d array
 */
func getNumRows (boardId: BoardIds) throws -> Int32 {
    var numRows: Int32 = 0
    let result = get_num_rows (boardId.rawValue, &numRows)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("Error in board info getter", result)
    }
    return numRows
}

/**
 * get row index in returned by get_board_data() 2d array which contains package nums
 */
func getPackageNumChannel (boardId: BoardIds) throws -> Int32 {
    var pkgNumChannel: Int32 = 0
    let result = get_package_num_channel (boardId.rawValue, &pkgNumChannel)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("Error in board info getter", result)
    }
    return pkgNumChannel
}

/**
 * get row index in returned by get_board_data() 2d array which contains battery level
 */
func getBatteryChannel (boardId: BoardIds) throws -> Int32 {
    var batteryChannel: Int32 = 0
    let result = get_battery_channel (boardId.rawValue, &batteryChannel)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("Error in board info getter", result)
    }
    return batteryChannel
}

/**
 * Get board description
 */
func getBoardDescr (boardId: BoardIds) throws -> String {
    var boardDescrStr = [CChar](repeating: CChar(0), count: 16000)
    var stringLen: Int32 = 0
    let result = get_board_descr (boardId.rawValue, &boardDescrStr, &stringLen)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("failed to get board info", result)
    }

    if let description = String(data: Data(bytes: &boardDescrStr, count: Int(stringLen)), encoding: .utf8) {
        return description }
    else {
        return "no data found"
    }
}

/**
 * Get device name
 */
func getDeviceName (boardId: BoardIds) throws -> String {
    var stringLen: Int32 = 0
    var deviceName = [CChar](repeating: CChar(0), count: 4096)
    let result = get_device_name (boardId.rawValue, &deviceName, &stringLen)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("Error in board info getter", result)
    }
    return deviceName.toString(stringLen)
}

/**
 * get row indices in returned by get_board_data() 2d array which contain EEG
 * data, for some boards we can not split EEG\EMG\... and return the same array
 */
func getEEGchannels (boardId: BoardIds) throws -> [Int32] {
    var len: Int32 = 0
    var channels = [Int32](repeating: 0, count: 512)
    let result = get_eeg_channels (boardId.rawValue, &channels, &len)
    let exitCode = BrainFlowExitCodes(rawValue: result)
    if exitCode != BrainFlowExitCodes.STATUS_OK {
        throw BrainFlowException ("Error in board info getter", result)
    }
    return Array(channels[0..<Int(len)])
}

//////////////////////////////////////////
/////// data acquisition methods /////////
//////////////////////////////////////////

struct BoardShim {
    let boardId: BoardIds
    let bfParams: BrainFlowInputParams
    private let jsonParams: String
    
    init (_ boardId: BoardIds, _ params: BrainFlowInputParams) {
        self.boardId = boardId
        self.bfParams = params
        self.jsonParams = params.json()
    }
    
    func prepareSession() throws {
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!
        let result = prepare_session(boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException("failed to prepare session", result)
        }
    }
    
    func isPrepared () throws -> Bool  {
        var intPrepared: Int32 = 0
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!
        let result = is_prepared (&intPrepared, boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("failed to check session", result)
        }
        guard let boolPrepared = Bool(exactly: NSNumber(value: intPrepared)) else {
            throw BrainFlowException ("is_prepared returned non-boolean", intPrepared)
        }
        return boolPrepared
    }

    func startStream (bufferSize: Int32, streamerParams: String) throws {
        var cStreamerParams = streamerParams.cString(using: String.Encoding.utf8)!
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!
        let result = start_stream (bufferSize, &cStreamerParams, boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("failed to start stream", result)
        }
    }
   
    func startStream() throws {
        try startStream(bufferSize: 450000, streamerParams: "")
    }
    
    func stopStream () throws {
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!
        let result = stop_stream (boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("failed to stop stream", result)
        }
    }

    func releaseSession () throws {
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!
        let result = release_session (boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("failed to release session", result)
        }
    }
    
    func getBoardDataCount () throws -> Int32 {
        var dataCount: Int32 = 0
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!
        let result = get_board_data_count (&dataCount, boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("failed to get board data count", result)
        }
        return dataCount
    }

    func getBoardId () throws -> BoardIds {
        let masterBoardId = boardId
        
        if ((boardId == BoardIds.STREAMING_BOARD) ||
            (boardId == BoardIds.PLAYBACK_FILE_BOARD)) {
            if let boardVal = Int32(bfParams.other_info) {
                if let actualBoardId = BoardIds(rawValue: boardVal) {
                    return actualBoardId
                }
            }
            else {
                throw BrainFlowException ("specify master board id using params.other_info",
                                          BrainFlowExitCodes.INVALID_ARGUMENTS_ERROR.rawValue)
            }
        }
        
        return masterBoardId
    }
        
    func getNumRows (boardId: BoardIds) throws -> Int32 {
        var numRows: Int32 = 0;
        let result = get_num_rows (boardId.rawValue, &numRows)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("failed to get board info", result)
        }
        return numRows
    }

    func getBoardData () throws -> [[Double]] {
        var size: Int32 = 0
        var numRows: Int32 = 0
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!

        do {
            size = try getBoardDataCount()
            guard size > 0 else {
                return [[Double]]()
            }
            numRows = try getNumRows (boardId: getBoardId()) }
        catch {
            throw error
        }
        
        var buffer = [Double](repeating: 0.0, count: Int(size * numRows))
        
        let result = get_board_data (size, &buffer, boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("failed to get board data", result)
        }

        return buffer.matrix2D(rowLength: Int(size))
    }
    
    /**
     * get latest collected data, can return less than "num_samples", doesnt flush
     * it from ringbuffer
     */
    func getCurrentBoardData (_ numSamples: Int32) throws -> [Double]
    {
        var numRows: Int32 = 0
        var currentSize: Int32 = 0
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!

        do {
            numRows = try getNumRows (boardId: getBoardId()) }
        catch {
            throw error
        }
            
        var buffer = [Double](repeating: 0.0, count: Int(numSamples * numRows))
        let result = get_current_board_data (numSamples, &buffer, &currentSize, boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("Error in get_current_board_data", result)
        }
        
        return buffer
    }
    
    /**
     * send string to a board, use this method carefully and only if you understand what you are doing
     */
    func configBoard (_ config: String) throws -> String {
        var responseLen: Int32 = 0
        var response = [CChar](repeating: CChar(0), count: 4096)
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!
        var cConfig = config.cString(using: String.Encoding.utf8)!

        let result = config_board (&cConfig, &response, &responseLen, boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("Error in config_board", result)
        }
        
        return response.toString(responseLen)        
    }
    
    /**
     * insert marker to data stream
     */
    func insertMarker (value: Double) throws {
        var cParams = jsonParams.cString(using: String.Encoding.utf8)!
        let result = insert_marker (value, boardId.rawValue, &cParams)
        let exitCode = BrainFlowExitCodes(rawValue: result)
        if exitCode != BrainFlowExitCodes.STATUS_OK {
            throw BrainFlowException ("Error in insert_marker", result)
        }
    }
}
