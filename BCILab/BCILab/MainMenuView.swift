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
    let callerVC: ExperimentVC
    @ObservedObject var appState: AppState
    
//    @Binding var saveFolder: String
//    @Binding var isMainMenuActive: Bool
    
    var body: some View {
        let id = "bluetooth"
        let label = "Connect to the headset"
        let connLink = NavigationLink(destination: RetryView(message: label, appState: self.appState)) {
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

        Color(.white)
        Spacer()
        NavigationView {
            VStack(alignment: .center, spacing: 2.0) {
                List {
                    connLink
                    fileSaveLink
                }.navigationBarTitle("Main Menu")
            }.border(Color.yellow, width: 1)
        }.frame(width: .infinity, height: .infinity, alignment: .topLeading)
         .border(Color.red, width: 1)
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

