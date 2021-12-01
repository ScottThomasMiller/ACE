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
    //@Binding var intervalSeconds: Double

    var body: some View {
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
                            NavigationLink(destination: Text("Hi")) {
                                NavLinkView(id: "folder", label: "Save Folder") }
                            NavigationLink(destination: ChangeIntervalView(intervalSeconds: self.$appState.intervalSeconds)) {
                                NavLinkView(id: "interval", label: "Slideshow Interval") }
                            NavigationLink(destination: ChangeHeadsetTypeView(boardId: self.$appState.boardId)) {
                                NavLinkView(id: "headset", label: "Headset Type") }
                        } // List
                        .navigationTitle("Main Menu")
                    } // ZStack
                } // NavigationView
                Spacer()
                AppStatusView(status)
                Spacer()
                Button(action: {appState.isMainMenuActive = false}) {
                    Text("Go Back")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)}.buttonStyle(GrowingButton(color: .blue))
                Spacer()
            } // VStack
        } // ZStack
        .frame(width: 900, height: 650, alignment: .center)
    }
} // MainMenuView
    

//struct MainMenuView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        @StateObject var appState = AppState()
//        return MainMenuView(headset: appState.headset, appState: appState)
//    }
//}
