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
    @State var interval: Double
    
    init(message: String, appState: AppState) {
        self.message = message
        self.appState = appState
        self.interval = appState.intervalSeconds
    }

    var body: some View {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()

        Text("Enter the new slideshow interval seconds:")
        TextField("interval seconds", value: $interval, formatter: formatter, onCommit: {
                self.appState.intervalSeconds = interval
                try? BoardShim.logMessage(.LEVEL_INFO, "new interval: \(self.appState.intervalSeconds) sec.")
                self.appState.isMainMenuActive = false
        })
         .fixedSize()
         .padding()
         .border(.blue, width: 2)
        
    }
}

