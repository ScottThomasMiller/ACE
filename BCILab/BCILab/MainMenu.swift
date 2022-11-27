//
//  MainMenuView.swift
//  BCILab
//
//  Created by Scott Miller on 9/25/21.
//

import SwiftUI
import Foundation

func timestamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    return (formatter.string(from: Date()) as NSString) as String
}

struct MainMenu: View {
    @Binding var isMainMenuActive: Bool
    @ObservedObject var appState: AppState
    let appGeometry: GeometryProxy

    func restartAction() {
        try? BoardShim.logMessage(.LEVEL_INFO, "restarting")
        self.isMainMenuActive = false
        self.appState.saveIndex = 0
    }
    
    func exitApp() {
        self.appState.headset.cleanup()
        sleep(1)
        exit(0)
    }
    
    var body: some View {
        let fWidth = 0.9*appGeometry.size.width
        let fHeight = 0.9*appGeometry.size.height
        ZStack {
            Color.white
            VStack(alignment: .center, spacing: 2.0) {
                let _ = try? BoardShim.logMessage(.LEVEL_INFO, "MainMenu body recompute")
                NavigationView {
                    ZStack {
                        Color.white
                        List {
                            NavigationLink(destination: ReconnectView(headset: self.$appState.headset,
                                                                      boardId: self.$appState.boardId,
                                                                      isMainMenuActive: self.$isMainMenuActive)) {
                                NavLinkView(id: "bluetooth", label: "Reconnect") }
                            
                            #if os(macOS)
                                NavigationLink(destination: ChangeSaveFolderView(saveFolderURL: self.$appState.saveFolder)) {
                                    NavLinkView(id: "save_folder", label: "Save Folder") }
                            #endif
                            NavigationLink(destination: ChangeLoadFolderView(loadFolderURL: self.$appState.loadFolder)) {
                                NavLinkView(id: "load_folder", label: "Load Folder") }
                            NavigationLink(destination: ChangeIntervalView(intervalSeconds: self.$appState.intervalSeconds)) {
                                NavLinkView(id: "interval", label: "Slideshow Interval") }
                            NavigationLink(destination: ChangeHeadsetTypeView(boardId: self.$appState.boardId, headset: self.$appState.headset)) {
                                NavLinkView(id: "headset", label: "Headset Type") }
                        } // List
                        .navigationTitle("Main Menu")
                    } // ZStack
                } // NavigationView
                Spacer()
                AppStatusView(appState: appState).frame(width: 0.9*fWidth, height: 0.18*fHeight, alignment: .center)
                Spacer()
                HStack() {
                    Button(action: {self.isMainMenuActive = false}) {
                        ButtonText("Resume", self.appGeometry)
                    }.buttonStyle(GrowingButton(color: .blue))
                    Button(action: { restartAction() }) {
                        ButtonText("Restart", self.appGeometry)
                    }.buttonStyle(GrowingButton(color: .blue))
                    Button(action: { exitApp() }) {
                        ButtonText("Exit", self.appGeometry)
                    }.buttonStyle(GrowingButton(color: .blue))
                     .keyboardShortcut("q", modifiers: [.command])
                }
                Spacer()
            } // VStack
        } // ZStack
        //.frame(width: 0.9*fWidth, height: 0.9*fHeight, alignment: .center)
    }
} // MainMenuView
    
//
//struct MainMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        @StateObject var appState = AppState()
//        return GeometryReader { geometry in
//            MainMenuView(appState: appState, appGeometry: geometry)
//        }
//    }
//}
