//
//  Experiment.swift
//  BCILab
//
//  Created by Scott Miller on 9/26/21.
//

import SwiftUI

// TabView timer code forked from: https://stackoverflow.com/questions/58896661/swiftui-create-image-slider-with-dots-as-indicators

class ImageState {
    var images: [LabeledImage] = prepareImages()
    var nextImages: [LabeledImage]?
    var isBuildingNextImages: Bool = false
}

struct ExperimentVC: View {
    let interval = 1.0
    @State var mainTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State var animationTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State var selection = -1
    @StateObject private var appState = AppState()
    private var imageState = ImageState()
    
    func buildNextImages() {
        try? BoardShim.logMessage(.LEVEL_INFO, "preparing next image set")
        self.imageState.nextImages = prepareImages()
        self.imageState.isBuildingNextImages = false
    }
    
    func manageSlideShow() {
        if (self.imageState.nextImages == nil) && !self.imageState.isBuildingNextImages {
            self.imageState.isBuildingNextImages = true
            DispatchQueue.global(qos: .background).async {
                self.buildNextImages() }}
        
        guard self.selection < (self.imageState.images.count-1) else {
            try? BoardShim.logMessage(.LEVEL_INFO, "experiment complete")
            if let board = self.appState.headset.board {
                try? board.insertMarker(value: ImageLabels.stop.rawValue) }
            self.stopTimer()
            return }
        
        if self.selection < 0 {
            try? BoardShim.logMessage(.LEVEL_INFO, "experiment is ready and paused")
            if let board = self.appState.headset.board {
                    try? board.insertMarker(value: ImageLabels.blank.rawValue) }
            self.selection = 0
            self.stopTimer() }
        else {
            let label = self.imageState.images[self.selection+1].label
            try? BoardShim.logMessage(.LEVEL_INFO, "marker: \(label)")
            if let board = self.appState.headset.board {
                try? board.insertMarker(value: label.rawValue) }
            self.selection += 1 }
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
    
    func resetTimer() {
        let secs = self.appState.intervalSeconds
        try? BoardShim.logMessage(.LEVEL_INFO, "resetting animation timer to \(secs) secs")
        stopTimer()
        startTimer()
    }
    
    func checkHeadset() {
        self.appState.isHeadsetReady = false
        self.appState.isHeadsetReady = (self.appState.headset.isActive && (self.appState.headset.board != nil))
                
        if !self.appState.isHeadsetReady {
            stopTimer()
            self.appState.headsetStatus = "not connected"
            self.appState.isMainMenuActive = true }
    }
    
    func insertAppears(_ image: LabeledImage) {
        if !image.appeared {
            let marker = image.label.rawValue + 100.0
            if let board = self.appState.headset.board {
                try? BoardShim.logMessage(.LEVEL_INFO, "on-appear marker: \(marker)")
                try? board.insertMarker(value: marker) }
            image.appeared = true }
    }
    
    func disconnectHeadset() {
        try? BoardShim.logMessage(.LEVEL_INFO, "disconnecting headset")
        stopTimer()
        self.appState.isHeadsetReady = false
        self.appState.headsetStatus = "disconnected"
        
        self.appState.headset.isActive = false
        self.appState.headset.isStreaming = false
        
        if let board = self.appState.headset.board {
            try? board.stopStream()
            try? board.releaseSession()
            self.appState.headset.board = nil }

        self.appState.headset.boardId = self.appState.boardId
//        if self.appState.headset.reconnect() {
//            self.appState.headsetStatus = "connected" }
    }
    
    var body: some View {
        GeometryReader { _ in 
            ZStack(alignment: .topLeading) {
            Color.black
                TabView(selection : self.$selection) {
                    ForEach(0..<self.imageState.images.count) { i in
                        Image(uiImage: self.imageState.images[i].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onAppear(perform: { insertAppears(self.imageState.images[i]) })
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .onChange(of: appState.intervalSeconds, perform: { _ in resetTimer() })
            .onChange(of: appState.boardId, perform: { _ in disconnectHeadset() })
            .onReceive(animationTimer, perform: { _ in manageSlideShow() })
            .onReceive(mainTimer, perform: { _ in checkHeadset() })
            .animation(nil)
            .onTapGesture { pauseResume() }
            .onLongPressGesture{ activateMenu() }
        }
        .fullScreenCover(isPresented: $appState.isMainMenuActive) {
            MainMenuView(headset: self.appState.headset, callerVC: self, appState: appState) }
//        .fullScreenCover(isPresented: $appState.isHeadsetReady) {
//            ReconnectView(message: "Connect to headset", appState: appState)  }
        }
    }

    func stopTimer() {
        guard self.appState.isTimerRunning else {
            return }
        try? BoardShim.logMessage(.LEVEL_INFO, "stopping timer")
        if let board = self.appState.headset.board {
            try? board.insertMarker(value: ImageLabels.stop.rawValue)}
        self.appState.headset.isStreaming = false
        self.animationTimer.upstream.connect().cancel()
        self.appState.isTimerRunning = false
    }
    
    func startTimer() {
        try? BoardShim.logMessage(.LEVEL_INFO, "start timer")
        self.appState.headset.isStreaming = true
        if let board = self.appState.headset.board {
            try? board.insertMarker(value: ImageLabels.start.rawValue) }
        
        let interval = Double(self.appState.intervalSeconds)
        self.animationTimer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
        self.appState.isTimerRunning = true
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

