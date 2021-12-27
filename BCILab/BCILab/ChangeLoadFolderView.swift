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
        if let fileURLs = try? contentsOfDirectory(at: folder,
                                                   includingPropertiesForKeys: [.isDirectoryKey]) {
            let folders = fileURLs.filter { (url) -> Bool in
                do {
                    let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
                    return resourceValues.isDirectory!
                } catch { return false }
            }
            return folders }
        else {
            return nil
        }
    }

    func imageURLs(of folder: URL ) -> [URL]? {
        let imageExts = ["jpg","jpeg","png"]
        if let fileURLs = try? contentsOfDirectory(at: folder, includingPropertiesForKeys: nil,
                                                   options: .skipsHiddenFiles) {
            let imageURLs = fileURLs.filter { url in imageExts.contains { $0 == url.pathExtension }}
            return imageURLs
        } else {
            return nil
        }
    }

// from: https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526
//    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
//        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
//        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
//        return fileURLs
//    }
}

struct ChangeLoadFolderView: View {
    @Binding var loadFolderURL: URL
    
    func validateFolder(folder: URL) -> Bool {
        var numValid = 0
        if let subFolders = FileManager.default.subFolders(of: folder) {
            guard subFolders.count > 0 else {
                try? BoardShim.logMessage(.LEVEL_ERROR, "no subfolders in load folder \(folder)")
                return false
            }

            for folder in subFolders {
                print("  subfolder: \(folder)")
                if let imageURLs = FileManager.default.imageURLs(of: folder) {
                    guard imageURLs.count > 0 else {
                        try? BoardShim.logMessage(.LEVEL_ERROR, "no images in subfolder \(folder)")
                        return false
                    }
                    numValid += 1
                }
            }
        }
        
        guard numValid > 0 else {
            try? BoardShim.logMessage(.LEVEL_INFO, "no valid subfolders in \(folder)")
            return false
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
                print("selectedURL: \(selectedURL)")
                if (selectedURL != self.loadFolderURL) && validateFolder(folder: selectedURL) {
                    self.loadFolderURL = selectedURL
                    try? BoardShim.logMessage(.LEVEL_INFO, "New load folder URL: \(selectedURL)") }}}
    }

    var body: some View {
        VStack {
            VStack (alignment: .leading, spacing: 10.0) {
                Text("Current load folder:").font(.title2)
                Text(self.loadFolderURL.lastPathComponent)
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
    

