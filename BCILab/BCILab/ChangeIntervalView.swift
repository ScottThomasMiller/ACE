//
//  ChangeIntervalView.swift
//  BCILab
//
//  Created by Scott Miller on 10/10/21.
//

import SwiftUI

struct ChangeIntervalView: View {
    let message: String
    @ObservedObject var appState: AppState
    @State var intervalString = ""
    
    init(message: String, appState: AppState) {
        self.message = message
        self.appState = appState
        self.intervalString = self.appState.intervalSeconds
    }

    var body: some View {
        Text("Enter the new animation interval seconds:")
        TextField("Enter interval seconds...", text: $intervalString, onCommit: {
                self.appState.intervalSeconds = intervalString
                try? BoardShim.logMessage(.LEVEL_INFO, "new interval: \(self.appState.intervalSeconds) sec.")
                self.appState.isMainMenuActive = false
        })
             .fixedSize()
             .padding()
             .border(.blue, width: 2)
        
    }
}

