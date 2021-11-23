
import SwiftUI

@main
struct BCILabMBApp: App {
    var body: some Scene {
        WindowGroup {
            ExperimentVC()
        }
        .commands {
            CommandMenu("Settings") {
                Button("Headset") { print("headset!") }
                    .keyboardShortcut("H")
            }
        }
    }
}
