//
//  AppState.swift
//  BCILab
//
//  Created by Scott Miller on 9/28/21.
//

import SwiftUI

class AppState: ObservableObject {
    static public let docsFolder: URL = Bundle.main.bundleURL

    @Published var saveFolder = Bundle.main.resourceURL!.appendingPathComponent("save")
    @Published var loadFolder = Bundle.main.resourceURL!.appendingPathComponent("images/default")
    @Published var intervalSeconds: Double = 0.6
    @Published var boardId: BoardIds = .SYNTHETIC_BOARD

    var saveIndex: Int?
    var isHeadsetReady : Bool { return self.headset.isActive && (self.headset.board != nil) }
    var headset = try! Headset(boardId: .SYNTHETIC_BOARD)
    var headsetStatus: String { return (self.isHeadsetReady ? "connected" : "disconnected") }
    var labels = ["Faces", "Non-faces"]
    var totalImages: Int = 200
}
