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
    @Published var intervalSeconds: String = "1.0"
    var headset: Headset?
    
//      8-channel:
//        @Published var boardId: BoardIds = .CYTON_BOARD
//    @Published var boardId: BoardIds = .SYNTHETIC_BOARD
//      16-channel:
        @Published var boardId: BoardIds = .CYTON_DAISY_BOARD

}
