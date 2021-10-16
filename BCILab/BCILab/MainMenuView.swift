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
            navLink(id: "filesave", label: label) }
        let label = "Change the slideshow interval"
        let intervalLink = NavigationLink(destination: ChangeIntervalView(message: label, appState: self.appState)) {
            navLink(id: "interval", label: label) }

        NavigationView {
            VStack(alignment: .center, spacing: 2.0) {
                List {
                    connLink
                    fileSaveLink
                    intervalLink
                }.navigationBarTitle("Main Menu")
            }.border(Color.yellow, width: 1)
        }.border(Color.red, width: 1)
        Spacer()
        Spacer()
        Button(action: {appState.isMainMenuActive = false}) {
            Text("Go Back")
                .fontWeight(.bold)
                .font(.title)
                .padding()
                .foregroundColor(.white)
        }
        .buttonStyle(GrowingButton(color: .blue))

    }
}
    
//    struct MainMenuView_Previews: PreviewProvider {
//        static var previews: some View {
//            Group {
//                MainMenuView()
//            }
//        }
//    }

