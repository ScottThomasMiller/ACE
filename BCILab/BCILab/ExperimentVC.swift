//
//  Experiment.swift
//  BCILab
//
//  Created by Scott Miller on 9/26/21.
//

import SwiftUI

// TabView timer code forked from: https://stackoverflow.com/questions/58896661/swiftui-create-image-slider-with-dots-as-indicators

struct ExperimentVC: View {
    let interval = 1.0
    @State var mainTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State var animationTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State var selection = -1
    @StateObject private var appState = AppState()
    private var images: [LabeledImage] = prepareImages()

    func manageSlideShow() {
        guard self.selection < (self.images.count-1) else {
            try? BoardShim.logMessage(.LEVEL_INFO, "experiment complete")
            if let tempHeadset = self.appState.headset {
                try? tempHeadset.board.insertMarker(value: ImageLabels.stop.rawValue) }
            self.stopTimer()
            return
        }
        
        if self.selection < 0 {
            try? BoardShim.logMessage(.LEVEL_INFO, "experiment is ready and paused")
            if let tempHeadset = self.appState.headset {
                try? tempHeadset.board.insertMarker(value: ImageLabels.blank.rawValue) }
            self.selection = 0
            self.stopTimer()
        } else {
            let label = self.images[self.selection+1].label
            try? BoardShim.logMessage(.LEVEL_INFO, "marker: \(label)")
            if let tempHeadset = self.appState.headset {
                try? tempHeadset.board.insertMarker(value: label.rawValue) }
            self.selection += 1
        }
    }
    
    func pauseResume() {
        if self.appState.isTimerRunning {
            self.stopTimer()
        } else {
            self.startTimer()
        }
    }
    
    func activateMenu() {
        stopTimer()
        self.appState.isTimerRunning = false
        self.appState.isMainMenuActive = true
    }
    
    func checkHeadset() {
        self.appState.isHeadsetNotReady = true
        if let tempHeadset = self.appState.headset {
            self.appState.isHeadsetNotReady = !tempHeadset.isActive
        }
        
        
        if self.appState.isHeadsetNotReady {
            if self.appState.isTimerRunning { stopTimer() }
            self.appState.isMainMenuActive = false
        }
    }
    
    func insertAppears(_ image: LabeledImage) {
        if let tempHeadset = self.appState.headset {
            if !image.appeared {
                let marker = image.label.rawValue + 100.0
                try? tempHeadset.board.insertMarker(value: marker)
                image.appeared = true } }
    }
    
    var body: some View {
        GeometryReader { _ in 
            ZStack(alignment: .topLeading) {
            Color.black
                TabView(selection : self.$selection) {
                    ForEach(0..<self.images.count) { i in
                    Image(uiImage: self.images[i].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onAppear(perform: { insertAppears(self.images[i]) })
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .onReceive(animationTimer, perform: { _ in manageSlideShow() })
            .onReceive(mainTimer, perform: { _ in checkHeadset() })
            .animation(nil)
            .onTapGesture { pauseResume() }
            .onLongPressGesture{ activateMenu() }
        }
        .fullScreenCover(isPresented: $appState.isMainMenuActive) {
            MainMenuView(headset: self.appState.headset, callerVC: self, appState: appState) }
        .fullScreenCover(isPresented: $appState.isHeadsetNotReady) {
            ReconnectView(message: "Reconnect to headset", appState: appState)  }
        }
    }

    func stopTimer() {
        try? BoardShim.logMessage(.LEVEL_INFO, "stop timer")
        if let tempHeadset = self.appState.headset {
            try? tempHeadset.board.insertMarker(value: ImageLabels.stop.rawValue)
            tempHeadset.isStreaming = false }
        self.animationTimer.upstream.connect().cancel()
        self.appState.isTimerRunning = false
    }
    
    func startTimer() {
        try? BoardShim.logMessage(.LEVEL_INFO, "start timer")
        if let tempHeadset = self.appState.headset {
            tempHeadset.isStreaming = true
            try? tempHeadset.board.insertMarker(value: ImageLabels.start.rawValue) }
        self.animationTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
        self.appState.isTimerRunning = true
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

