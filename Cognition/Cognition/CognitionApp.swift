//
//  CognitionApp.swift
//  Cognition
//
//  Created by Scott Miller on 11/24/22.
//

import SwiftUI

@main
struct CognitionApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
