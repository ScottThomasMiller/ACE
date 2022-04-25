//
//  ChangeSaveFolder.swift
//  BCILab
//
//  Created by Scott Miller on 9/26/21 for Aeris Rising, LLC.
//


import SwiftUI
import Foundation

struct ChangeSaveFolderView: View {
    @Binding var saveFolderURL: URL

    func pickFolder() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
 
        print("pickFolder()")
        if panel.runModal() == .OK {
            if let selectedURL = panel.url {
                if selectedURL != self.saveFolderURL {
                    self.saveFolderURL = selectedURL
                    try? BoardShim.logMessage(.LEVEL_INFO, "selected save folder URL: \(selectedURL)") }}}
        #endif
    }

    var body: some View {
        VStack {
            VStack (alignment: .leading, spacing: 10.0) {
                Text("Current save folder:").font(.title2)
                Text(self.saveFolderURL.lastPathComponent)
                Spacer()
                Button("Change") {
                    pickFolder()
                }.buttonStyle(GrowingButton(color: .blue))
            }
        }
        .font(.title2)
        .foregroundColor(.black)
        .fixedSize()
    }
  }
    

