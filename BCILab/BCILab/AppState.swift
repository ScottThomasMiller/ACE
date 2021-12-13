//
//  AppState.swift
//  BCILab
//
//  Created by Scott Miller on 9/28/21.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isTimerRunning = true
    @Published var isPresented: Bool = true
    @Published var isMainMenuActive: Bool = true
    @Published var isHeadsetReady: Bool = false
    @Published var saveFolder: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    @Published var loadFolder: URL = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/DefaultImages")
    @Published var intervalSeconds: Double = 1.0
    @Published var boardId: BoardIds = .SYNTHETIC_BOARD

    var headset = try! Headset(boardId: .SYNTHETIC_BOARD)
    var headsetStatus = "not connected"
}
