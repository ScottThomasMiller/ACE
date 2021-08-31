//
//  Matrix.swift
//  BrainBook
//
//  Created by Scott Miller on 8/25/21.
//

import Foundation

extension Array {
    func matrix2D(rowLength: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: rowLength).map {
            Array(self[$0 ..< Swift.min($0 + rowLength, count)])
        }
    }
}

extension Array where Element == CChar {
    //  convert an array of characters returned from a C++ API, into a String
    func toString(_ len: Int32) -> String {
        let data = Data(bytes: self, count: Int(len))
        if let result = String(data: data, encoding: .utf8) {
            return result }
        else {
            return "*** Array.toString: INVALID [CChar] ***"
        }
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}


