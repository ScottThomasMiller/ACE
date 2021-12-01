
import SwiftUI

@main
struct BCILabMBApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandMenu("Settings") {
                Button("Headset") { print("headset!") }
                    .keyboardShortcut("H")
            }
        }
    }
}
