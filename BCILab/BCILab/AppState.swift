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
    @Published var isHeadsetReady: Bool = false
    @Published var saveFolder = "BrainWaves"
    @Published var newBoardId: BoardIds = .SYNTHETIC_BOARD
}
