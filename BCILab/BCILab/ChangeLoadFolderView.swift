//
//  ChangeLoadFolderView.swift
//  BCILab
//
//  Created by Scott Miller on 12/4/21.
//

import SwiftUI
import Foundation

extension FileManager {
    func subFolders(of folder: URL ) -> [URL]? {
        print("subFolders(\(folder))")
        let props = [URLResourceKey]()
        let fileURLs = try? contentsOfDirectory(at: folder, includingPropertiesForKeys: props,
                                                options: .skipsHiddenFiles)
        print ("props:\n\(props)")
        print("fileURLs: \(String(describing: fileURLs))")

        return fileURLs
    }

    func countImages(of folder: URL ) -> Int {
        print("countImages(\(folder))")
        let count = 0
        let props = [URLResourceKey]()
        let fileURLs = try? contentsOfDirectory(at: folder, includingPropertiesForKeys: props,
                                                options: .skipsHiddenFiles)
        print ("countImages() props:\n\(props)")
        print("fileURLs: \(String(describing: fileURLs))")

        return count
    }

    // from: https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}

struct ChangeLoadFolderView: View {
    @Binding var loadFolderURL: URL
    
    func validateFolder() -> Bool {
        if let subFolders = FileManager.default.subFolders(of: self.loadFolderURL) {
            guard subFolders.count > 0 else {
                try? BoardShim.logMessage(.LEVEL_INFO, "no subfolders in load folder \(self.loadFolderURL)")
                return false
            }

            for folder in subFolders {
                guard FileManager.default.countImages(of: folder) > 0 else {
                    try? BoardShim.logMessage(.LEVEL_INFO, "no images in subfolder \(folder)")
                    return false
                }
            }
        }
        
        return true
    }
    
    func pickFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
 
        print("pickFolder()")
        if panel.runModal() == .OK {
            if let selectedURL = panel.url {
                if (selectedURL != self.loadFolderURL) && validateFolder() {
                    self.loadFolderURL = selectedURL
                    try? BoardShim.logMessage(.LEVEL_INFO, "New load folder URL: \(selectedURL)") }}}
    }

    var body: some View {
        VStack {
            VStack (alignment: .leading, spacing: 10.0) {
                Text("Current load folder:").font(.title2)
                Text(self.loadFolderURL.relativeString)
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
    

