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
    @Published var isHeadsetNotReady: Bool = false
    @Published var saveFolder = "BrainWaves"
    @Published var boardId: BoardIds = .CYTON_DAISY_BOARD
}
