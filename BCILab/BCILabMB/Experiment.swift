//
//  Experiment.swift
//  BCILab
//
//  Created by Scott Miller on 9/26/21.
//
import SwiftUI

struct Experiment: View {
    @StateObject private var appState = AppState()
    @State private var mainTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State var isMainMenuActive = false
    let interval = 1.0
    
    private func checkHeadset() {
        if !self.appState.isHeadsetReady {
            self.isMainMenuActive = true }
    }
        
    private func disconnectHeadset() {
        try? BoardShim.logMessage(.LEVEL_INFO, "disconnecting headset")
        
        self.appState.headset.isActive = false
        self.appState.headset.isStreaming = false
        
        if let board = self.appState.headset.board {
            try? board.stopStream()
            try? board.releaseSession()
            self.appState.headset.board = nil }

        self.appState.headset.boardId = self.appState.boardId
    }

    private func updateSaveFolder() {
        try? BoardShim.logMessage(.LEVEL_INFO, "Updating the headset's save folder to \(self.appState.saveFolder)")
        self.appState.headset.saveURL =  self.appState.saveFolder
    }
    
    var body: some View {
        let _ = try? BoardShim.logMessage(.LEVEL_INFO, "Experiment body recompute")
        GeometryReader { geometry in
             ZStack { SlideShow(isMainMenuActive: self.$isMainMenuActive, appState: self.appState) }
                .onChange(of: self.appState.boardId, perform: { _ in disconnectHeadset() })
                .onReceive(mainTimer, perform: { _ in checkHeadset() })
                .sheet(isPresented: self.$isMainMenuActive) {
                    MainMenu(isMainMenuActive: self.$isMainMenuActive,
                             appState: self.appState,
                             appGeometry: geometry) }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

