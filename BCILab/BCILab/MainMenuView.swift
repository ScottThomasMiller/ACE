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

struct MainMenuView: View {
    @ObservedObject var appState: AppState
    let appGeometry: GeometryProxy

    var body: some View {
        let fWidth = appGeometry.size.width
        let fHeight = 0.9*appGeometry.size.height
        ZStack {
            Color.white
            VStack(alignment: .center, spacing: 2.0) {
                let _ = print("[\(timestamp())] MainMenuView.body")
                let status = StatusRec(imagesCount: self.appState.images.count,
                                       headsetStatus: self.appState.headsetStatus,
                                       boardName: self.appState.boardId.name)
                
                NavigationView {
                    ZStack {
                        Color.white
                        List {
                            NavigationLink(destination: ReconnectView(headset: self.$appState.headset,
                                                                      boardId: self.$appState.boardId,
                                                                      headsetStatus: self.$appState.headsetStatus,
                                                                      isMainMenuActive: self.$appState.isMainMenuActive,
                                                                      isHeadsetReady: self.$appState.isHeadsetReady)) {
                                NavLinkView(id: "bluetooth", label: "Reconnect") }
                            NavigationLink(destination: ChangeSaveFolderView(folderURL: self.$appState.saveFolder)) {
                                NavLinkView(id: "save_folder", label: "Save Folder") }
                            NavigationLink(destination: ChangeLoadFolderView(loadFolderURL: self.$appState.loadFolder)) {
                                NavLinkView(id: "load_folder", label: "Load Folder") }
                            NavigationLink(destination: ChangeIntervalView(intervalSeconds: self.$appState.intervalSeconds)) {
                                NavLinkView(id: "interval", label: "Slideshow Interval") }
                            NavigationLink(destination: ChangeHeadsetTypeView(boardId: self.$appState.boardId)) {
                                NavLinkView(id: "headset", label: "Headset Type") }
                        } // List
                        .navigationTitle("Main Menu")
                    } // ZStack
                }//.frame(width: 0.9*fWidth, height: 0.72*fHeight, alignment: .center) // NavigationView
                Spacer()
                AppStatusView(status).frame(width: 0.9*fWidth, height: 0.18*fHeight, alignment: .center)
                Spacer()
                Button(action: {appState.isMainMenuActive = false}) {
                    Text("Go Back")
                        .fontWeight(.bold)
                        .font(.title2)
                        .padding()
                        .foregroundColor(.white)}.buttonStyle(GrowingButton(color: .blue))
                Spacer()
            } // VStack
        } // ZStack
        .frame(width: 0.9*fWidth, height: 0.9*fHeight, alignment: .center)
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
