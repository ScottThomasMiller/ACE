//
//  BCILabTests.swift
//  BCILabTests
//
//  Created by Scott Miller on 7/24/21.
//

import XCTest
@testable import BCILab

class BCILabTests: XCTestCase {
    let boardId = BoardIds.SYNTHETIC_BOARD
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEEGnames() throws {
        let result = try getEEGnames(boardId: boardId)
        XCTAssert(result == ["Fz", "C3", "Cz", "C4", "Pz", "PO7", "Oz", "PO8", "F5", "F7", "F3", "F1", "F2", "F4", "F6", "F8"])
    }

    func testSamplingRate() throws {
        let result = try getSamplingRate(boardId: boardId)
        XCTAssert(result == 250)
    }
    
    func testTimestampChannel () throws {
        let result = try getTimestampChannel(boardId: boardId)
        XCTAssert(result == 30)
    }

    func testMarkerChannel () throws {
        let result = try getMarkerChannel(boardId: boardId)
        XCTAssert(result == 31)
    }
    
    func testNumRows () throws {
        let result = try getNumRows(boardId: boardId)
        XCTAssert(result == 32)
    }

    func testPackageNumChannel () throws {
        let result = try getPackageNumChannel(boardId: boardId)
        XCTAssert(result == 0)
    }

    func testBatteryChannel () throws {
        let result = try getBatteryChannel(boardId: boardId)
        XCTAssert(result == 29)
    }

    func testBoardDescr () throws {
        let result = try getBoardDescr(boardId: boardId)
        XCTAssert(result ==
                    """
                    {"accel_channels":[17,18,19],"battery_channel":29,"ecg_channels":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],"eda_channels":[23],"eeg_channels":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],"eeg_names":"Fz,C3,Cz,C4,Pz,PO7,Oz,PO8,F5,F7,F3,F1,F2,F4,F6,F8","emg_channels":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],"eog_channels":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],"gyro_channels":[20,21,22],"marker_channel":31,"name":"Synthetic","num_rows":32,"package_num_channel":0,"ppg_channels":[24,25],"resistance_channels":[27,28],"sampling_rate":250,"temperature_channels":[26],"timestamp_channel":30}
                    """)
    }


    /**
     * Get board description
     */
    func getBoardDescr (boardId: BoardIds) throws -> String {
        var boardDescrStr = [CChar](repeating: CChar(0), count: 16000)
        var stringLen: Int32 = 0
        let result = get_board_descr (boardId.rawValue, &boardDescrStr, &stringLen)
        try checkErrorCode(errorMsg: "failed to get board info", errorCode: result)

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
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

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
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain EMG
     * data, for some boards we can not split EEG\EMG\... and return the same array
     */
    func getEMGchannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_emg_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain ECG
     * data, for some boards we can not split EEG\EMG\... and return the same array
     */
    func getECGchannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_ecg_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain
     * temperature data
     */
    func getTemperatureChannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_temperature_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain
     * resistance data
     */
    func getReistanceChannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_resistance_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain EOG
     * data, for some boards we can not split EEG\EMG\... and return the same array
     */
    func getEOGchannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_eog_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain EXG
     * data
     */
    func getEXGchannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_exg_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain EDA
     * data, for some boards we can not split EEG\EMG\... and return the same array
     */
    func getEDAchannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_eda_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain PPG
     * data, for some boards we can not split EEG\EMG\... and return the same array
     */
    func getPPGchannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_ppg_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain accel
     * data
     */
    func getAccelChannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_accel_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain analog
     * data
     */
    func getAnalogChannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_analog_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
      * get row indices in returned by get_board_data() 2d array which contain gyro
      * data
      */
    func getGyroChannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_gyro_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /**
     * get row indices in returned by get_board_data() 2d array which contain other
     * data
     */
    func getOtherChannels (boardId: BoardIds) throws -> [Int32] {
        var len: Int32 = 0
        var channels = [Int32](repeating: 0, count: 512)
        let result = get_other_channels (boardId.rawValue, &channels, &len)
        try checkErrorCode(errorMsg: "Error in board info getter", errorCode: result)

        return Array(channels[0..<Int(len)])
    }

    /*
     If the board is streaming or playback, then get the master board ID from params.other_info.
     Otherwise return the board ID itself.
     */
    func getMasterBoardID(boardId: BoardIds, params: BrainFlowInputParams) throws -> BoardIds {
        guard ((boardId == BoardIds.STREAMING_BOARD) || (boardId == BoardIds.PLAYBACK_FILE_BOARD)) else {
            return boardId
        }
        if let otherInfoInt = Int32(params.other_info) {
            if let masterBoardId = BoardIds(rawValue: otherInfoInt) {
                return masterBoardId
            }
        }
        throw BrainFlowException ("need to set params.otherInfo to master board id",
                                  BrainFlowExitCodes.INVALID_ARGUMENTS_ERROR)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
