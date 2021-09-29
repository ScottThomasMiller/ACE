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
    @State var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State var selection = -1
    @StateObject private var appState = AppState()
    private var boardId: BoardIds = .SYNTHETIC_BOARD
    private let images: [LabeledImage] = prepareImages()
    private var headset = try! Headset(boardId: .SYNTHETIC_BOARD)
    
    func dismissMainMenu() {
        print("dismissMainMenu()")
        appState.isMainMenuActive = false
    }
    
    var body: some View {
        ZStack {
            Color.black
            TabView(selection : $selection){
                ForEach(0..<images.count){ i in
                    Image(uiImage: self.images[i].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .onReceive(timer, perform: { _ in
                withAnimation{
                    guard self.selection < (self.images.count-1) else {
                        print("done")
                        self.stopTimer()
                        return
                    }
                    if self.selection < 0 {
                        print("pause")
                        try? self.headset.board.insertMarker(value: ImageLabels.blank.rawValue)
                        self.selection = 0
                        self.stopTimer()
                    } else {
                        let label = self.images[self.selection+1].label
                        print("marker: \(label)")
                        try? self.headset.board.insertMarker(value: label.rawValue)
                        self.selection += 1
                    }
                }
            })
            .animation(nil)
            .onTapGesture {
                if self.appState.isTimerRunning {
                    self.stopTimer()
                } else {
                    self.startTimer()
                }
                self.appState.isTimerRunning.toggle()
            }
            .onLongPressGesture{
                self.appState.isMainMenuActive.toggle()
            }
        }
        .fullScreenCover(isPresented: $appState.isMainMenuActive) {
            MainMenuView(callerVC: self, headset: self.headset, appState: appState) }
        .fullScreenCover(isPresented: $appState.isHeadsetReady) {
            RetryView(message: "Reconnect to headset", headset: self.headset, appState: appState)  }
    }

    init () {
        do {
            self.appState.isHeadsetReady = try self.headset.board.isPrepared()
        } catch {
            try? BoardShim.logMessage(.LEVEL_ERROR, "Failed to initialize headset")
            self.appState.isHeadsetReady = false
        }
    }
    
    func stopTimer() {
        print("stop timer")
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        print("start timer")
        self.timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

