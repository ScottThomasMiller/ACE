//
//  BoardDescription.swift
//  BrainBook
//
//  Created by Scott Miller on 8/29/21.
//{{"name", "Synthetic"},
//{"sampling_rate", 250},
//{"package_num_channel", 0},
//{"battery_channel", 29},
//{"timestamp_channel", 30},
//{"marker_channel", 31},
//{"num_rows", 32},
//{"eeg_channels", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}},
//{"eeg_names", "Fz,C3,Cz,C4,Pz,PO7,Oz,PO8,F5,F7,F3,F1,F2,F4,F6,F8"},
//{"emg_channels", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}},
//{"ecg_channels", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}},
//{"eog_channels", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}},
//{"accel_channels", {17, 18, 19}},

//{"gyro_channels", {20, 21, 22}},
//{"eda_channels", {23}},
//{"ppg_channels", {24, 25}},
//{"temperature_channels", {26}},
//{"resistance_channels", {27, 28}}

//{"2",
//    {{"name", "CytonDaisy"},
//    {"sampling_rate", 125},
//    {"package_num_channel", 0},
//    {"timestamp_channel", 30},
//    {"marker_channel", 31},
//    {"num_rows", 32},
//    {"eeg_channels", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}},
//    {"eeg_names", "Fp1,Fp2,C3,C4,P7,P8,O1,O2,F7,F8,F3,F4,T7,T8,P3,P4"},
//    {"emg_channels", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}},
//    {"ecg_channels", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}},
//    {"eog_channels", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}},
//    {"accel_channels", {17, 18, 19}},

//    {"analog_channels", {27, 28, 29}},
//    {"other_channels", {20, 21, 22, 23, 24, 25, 26}}
//}}
//
//
import Foundation

//typealias JSONDict = [String:AnyObject]

class BasicBoardDescription {
    var name: String = ""
    var sampling_rate: Int = 0
    var package_num_channel: Int = 0
    var timestamp_channel: Int = 0
    var marker_channel: Int = 0
    var num_rows: Int = 0
    var eeg_channels = [Int]()
    var eeg_names = [String]()
    var emg_channels =  [Int]()
    var ecg_channels = [Int]()
    var eog_channels = [Int]()
    var accel_channels = [Int]()
    
    init(jsonString: String) {
        if let jsonDict = jsonString.convertToDictionary() {
            name = jsonDict["name"] as! String
            sampling_rate = jsonDict["sampling_rate"] as! Int
            package_num_channel = jsonDict["package_num_channel"] as! Int
            timestamp_channel = jsonDict["timestamp_channel"] as! Int
            marker_channel = jsonDict["marker_channel"] as! Int
            num_rows = jsonDict["num_rows"] as! Int
            eeg_channels = jsonDict["eeg_channels"] as! [Int]
            eeg_names = jsonDict["eeg_names"] as! [String]
            emg_channels = jsonDict["emg_channels"] as! [Int]
            ecg_channels = jsonDict["ecg_channels"] as! [Int]
            eog_channels = jsonDict["eog_channels"] as! [Int]
            accel_channels = jsonDict["accel_channels"] as! [Int]
        } else {
            try? logMessage (logLevel: LogLevels.LEVEL_ERROR.rawValue, message: "Invalid JSON string for board description")

        }
    }
}

class SyntheticDescription: BasicBoardDescription {
    var gyro_channels = [Int]()
    var eda_channels = [Int]()
    var ppg_channels = [Int]()
    var temperature_channels = [Int]()
    var resistance_channels = [Int]()
    
    override init(jsonString: String) {
        super.init(jsonString: jsonString)
        if let jsonDict = jsonString.convertToDictionary() {
            gyro_channels = jsonDict["gyro_channels"] as! [Int]
            eda_channels = jsonDict["eda_channels"] as! [Int]
            ppg_channels = jsonDict["ppg_channels"] as! [Int]
            temperature_channels = jsonDict["temperature_channels"] as! [Int]
            resistance_channels = jsonDict["resistance_channels"] as! [Int]
        }
    }
}

class CytonDaisyDescription: BasicBoardDescription {
    var analog_channels = [Int]()
    var other_channels = [Int]()
    
    override init(jsonString: String) {
        super.init(jsonString: jsonString)
        if let jsonDict = jsonString.convertToDictionary() {
            analog_channels = jsonDict["analog_channels"] as! [Int]
            other_channels = jsonDict["other_channels"] as! [Int]
        }
    }
}
