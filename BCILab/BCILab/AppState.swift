//
//  AppState.swift
//  BCILab
//
//  Created by Scott Miller on 9/28/21.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isTimerRunning = false
    @Published var isPresented: Bool = true
    @Published var isMainMenuActive: Bool = false
    @Published var isHeadsetNotReady: Bool = true
    @Published var saveFolder = "BrainWaves"
    @Published var boardId: BoardIds = .CYTON_DAISY_BOARD
    @Published var headset: Headset = try! Headset(boardId: .SYNTHETIC_BOARD)
}
