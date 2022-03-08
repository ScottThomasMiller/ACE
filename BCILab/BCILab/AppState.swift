//
//  AppState.swift
//  BCILab
//
//  Created by Scott Miller on 9/28/21.
//

import SwiftUI

class AppState: ObservableObject {
    static public let docsFolder: URL = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/DefaultImages")
    
    @Published var loadFolder = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/DefaultImages")
    @Published var intervalSeconds: Double = 0.6
    @Published var boardId: BoardIds = .SYNTHETIC_BOARD
    @Published var saveIndex: Int?

    var isHeadsetReady : Bool { return self.headset.isActive && (self.headset.board != nil) }
    var headset = try! Headset(boardId: .SYNTHETIC_BOARD)
    var headsetStatus: String { return (self.isHeadsetReady ? "connected" : "disconnected") }
    var saveFolder = URL(fileURLWithPath: "BCILab", relativeTo: docsFolder)
    var labels = [String]()
    var totalImages: Int = 0
}
