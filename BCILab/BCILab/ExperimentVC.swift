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
    
//    init() {
//        do {
//            self.headset = try Headset(boardId: .CYTON_DAISY_BOARD)
////            let headsetCopy = headset!
////            DispatchQueue.global(qos: .background).async {
////                headsetCopy.streamEEG()
////            }
//        }
//        catch {
//            try? BoardShim.logMessage(.LEVEL_ERROR, "Cannot connect to headset")
//        }
//    }
    
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
                        if let tempHeadset = self.appState.headset {
                            try? tempHeadset.board.insertMarker(value: ImageLabels.stop.rawValue) }
                        self.stopTimer()
                        return
                    }
                    
                    if self.selection < 0 {
                        print("pause")
                        if let tempHeadset = self.appState.headset {
                            try? tempHeadset.board.insertMarker(value: ImageLabels.blank.rawValue) }
                        self.selection = 0
                        self.stopTimer()
                    } else {
                        let label = self.images[self.selection+1].label
                        print("marker: \(label)")
                        if let tempHeadset = self.appState.headset {
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
            MainMenuView(headset: self.appState.headset, callerVC: self, appState: appState) }
        .fullScreenCover(isPresented: $appState.isHeadsetNotReady) {
            ReconnectView(message: "Reconnect to headset", appState: appState)  }
        .onAppear(perform: {print("ExperimentVC appears")})
    }

    func stopTimer() {
        print("stop timer")
        if let tempHeadset = self.appState.headset {
            tempHeadset.isStreaming = false
            try? tempHeadset.board.insertMarker(value: ImageLabels.stop.rawValue) }
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        print("start timer")
        if let tempHeadset = self.appState.headset {
            tempHeadset.isStreaming = true
            try? tempHeadset.board.insertMarker(value: ImageLabels.start.rawValue) }
        self.timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

