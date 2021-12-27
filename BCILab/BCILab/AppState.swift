//
//  AppState.swift
//  BCILab
//
//  Created by Scott Miller on 9/28/21.
//

import SwiftUI

class AppState: ObservableObject {
    static var docDir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    @Published var isTimerRunning = true
    @Published var isPresented: Bool = true
    @Published var isMainMenuActive: Bool = true
    @Published var isHeadsetReady: Bool = false
    @Published var saveFolder = URL(fileURLWithPath: "BCILab", relativeTo: docDir)
    @Published var loadFolder: URL = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/DefaultImages")
    @Published var intervalSeconds: Double = 0.6
    @Published var boardId: BoardIds = .SYNTHETIC_BOARD

    var headset = try! Headset(boardId: .SYNTHETIC_BOARD)
    var headsetStatus = "not connected"
}
