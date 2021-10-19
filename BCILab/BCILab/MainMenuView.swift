//
//  MainMenuView.swift
//  BCILab
//
//  Created by Scott Miller on 9/25/21.
//

import SwiftUI
import Foundation
import UIKit

struct MainMenuView: View {
    var headset: Headset?
    let callerVC: ExperimentVC
    @ObservedObject var appState: AppState
    
    func navLink(id: String, label: String) -> some View {
        HStack(alignment: .center) {
            Text(label)
                .fontWeight(.bold)
                .font(.title)
                .padding()
                .foregroundColor(.black)
            Spacer(minLength: 2)
            Image(id).resizable().frame(width: 40, height: 40)
        }
    }
    
    var body: some View {
        let label = "Reconnect to the headset"
        let connLink = NavigationLink(destination: ReconnectView(message: label, appState: self.appState)) {
            navLink(id: "bluetooth", label: label) }
        let label = "Change the save folder"
        let fileSaveLink = NavigationLink(destination: ChangeSaveFolderView(message: label, appState: self.appState)) {
            navLink(id: "folder", label: label) }
        let label = "Change the slideshow interval"
        let intervalLink = NavigationLink(destination: ChangeIntervalView(message: label, appState: self.appState)) {
            navLink(id: "interval", label: label) }
        let label = "Change the headset type"
        let headsetLink = NavigationLink(destination: ChangeHeadsetTypeView(message: label, appState: self.appState)) {
            navLink(id: "headset", label: label) }
        let statusColor: Color = (self.appState.headsetStatus == "connected") ? .green : .red

        NavigationView {
            VStack(alignment: .center, spacing: 2.0) {
                List {
                    connLink
                    fileSaveLink
                    intervalLink
                    headsetLink
                }.navigationBarTitle("Main Menu")
            }
        }
        Spacer(minLength: 100)
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("Headset status:").bold().font(.largeTitle)
                Text("Headset type:").bold().font(.largeTitle)
            }
            VStack(alignment: .trailing) {                Text("\(self.appState.headsetStatus)").bold().font(.largeTitle).foregroundColor(statusColor)
                Text("\(self.appState.boardId.name)").bold().font(.title).foregroundColor(.blue)
            }
        }
        Spacer(minLength: 100)
        Button(action: {appState.isMainMenuActive = false}) {
            Text("Go Back")
                .fontWeight(.bold)
                .font(.title)
                .padding()
                .foregroundColor(.white)
        }
        .buttonStyle(GrowingButton(color: .blue))
        Spacer()
    }
}
    
//    struct MainMenuView_Previews: PreviewProvider {
//        static var previews: some View {
//            Group {
//                MainMenuView()
//            }
//        }
//    }

