//
//  MainMenuView.swift
//  BCILab
//
//  Created by Scott Miller on 9/25/21.
//

import SwiftUI
import Foundation
//import UIKit

struct MainMenuView: View {
    var headset: Headset?
    let callerVC: ExperimentVC
    @ObservedObject var appState: AppState
    
    var setReconnectState: some View {
        self.appState.isHeadsetNotReady = true
        return Text("Reconnecting")
    }
    
    var body: some View {
        let id = "bluetooth"
        let label = "Connect to the headset"
        //let connLink = NavigationLink(destination: ReconnectView(message: label, appState: self.appState)) {
        let connLink = NavigationLink(destination: setReconnectState) {
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

        let id = "filesave"
        let label = "Change the save folder"
        let fileSaveLink = NavigationLink(destination: ChangeSaveFolderView(message: label, appState: self.appState)) {
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
        
        VStack (alignment: .center) {
            //Color(.white)
            NavigationView {
                VStack(alignment: .center, spacing: 2.0) {
                    List {
                        connLink
                        fileSaveLink
                    }.navigationBarTitle("Main Menu")
                }
            }
            Spacer()
            Button(action: {appState.isMainMenuActive = false}) {
                Text("Go Back")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
            }
            .buttonStyle(GrowingButton(color: .blue))
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
         .border(Color.orange, width: 4)
    }
}
//
//    struct MainMenuView_Previews: PreviewProvider {
//        static var previews: some View {
//            Group {
//                MainMenuView()
//            }
//        }
//    }

