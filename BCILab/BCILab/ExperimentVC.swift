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
    private let images: [LabeledImage] = prepareImages()
    private var headset: Headset?
    
    init() {
        do {
            self.headset = try Headset(boardId: .CYTON_DAISY_BOARD)
//            let headsetCopy = headset!
//            DispatchQueue.global(qos: .background).async {
//                headsetCopy.streamEEG()
//            }
        }
        catch {
            try? BoardShim.logMessage(.LEVEL_CRITICAL, "Cannot connect to headset")
            exit(-1)
        }
    }
    
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
                        if let tempHeadset = self.headset {
                            try? tempHeadset.board.insertMarker(value: ImageLabels.blank.rawValue) }
                        self.selection = 0
                        self.stopTimer()
                    } else {
                        let label = self.images[self.selection+1].label
                        print("marker: \(label)")
                        if let tempHeadset = self.headset {
                            try? tempHeadset.board.insertMarker(value: label.rawValue) }
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
            MainMenuView(headset: self.headset, callerVC: self, appState: appState) }
        .fullScreenCover(isPresented: $appState.isHeadsetNotReady) {
            RetryView(headset: self.headset, message: "Reconnect to headset", appState: appState)  }
    }

    func stopTimer() {
        print("stop timer")
        self.timer.upstream.connect().cancel()
        if let tempHeadset = self.headset {
            tempHeadset.isStreaming = false
        }
    }
    
    func startTimer() {
        print("start timer")
        self.timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
        if let tempHeadset = self.headset {
            tempHeadset.isStreaming = true
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

