//
//  BCILabApp.swift
//  BCILab
//
//  Created by Scott Miller on 7/24/21.
//

import SwiftUI

@main
struct BCILabApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.white
                ContentView()
            }
        }
//        .commands {
//            CommandMenu("Settings") {
//                Button("Headset") { print("headset!") }
//                    .keyboardShortcut("H")
//            }
//        }
    }
}
