//
//  ChangeLoadFolderView.swift
//  BCILab
//
//  Created by Scott Miller on 12/4/21.
//

import SwiftUI
import Foundation

extension FileManager {
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func subFolders(of folder: URL ) -> [URL] {
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
            return [URL]()
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
}

struct ChangeLoadFolderView: View {
    @Binding var loadFolderURL: URL
    
    private func validateFolder(folder: URL) -> Bool {
        var numValid = 0
        let subFolders = FileManager.default.subFolders(of: folder)
        guard subFolders.count > 0 else {
            try? BoardShim.logMessage(.LEVEL_ERROR, "no subfolders in load folder \(folder)")
            return false
        }

        for folder in subFolders {
            if let imageURLs = FileManager.default.imageURLs(of: folder) {
                guard imageURLs.count > 0 else {
                    try? BoardShim.logMessage(.LEVEL_ERROR, "no images in subfolder \(folder)")
                    return false
                }
                numValid += 1
            }
        }
        
        guard numValid > 0 else {
            try? BoardShim.logMessage(.LEVEL_INFO, "no valid subfolders in \(folder)")
            return false
        }
        
        return true
    }

    private func pickFoldermacOS() {
        #if os(macOS)
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
        #endif
    }

    var body: some View {
        let pickerLabel = Text("").foregroundColor(.black)
        let files = FileManager()
        let folders = files.subFolders(of: files.getDocumentsDirectory())
        ZStack {
            Color.white
            VStack(alignment: .leading, spacing: 10) {
                ScrollView(showsIndicators: true) {
                    Picker(selection: self.$loadFolderURL, label: pickerLabel) {
                        ForEach(folders, id: \.self) { value in
                            Text(String(value.lastPathComponent))
                                .font(.title2)
                                .foregroundColor(.black)
                                .tag(value)
                        }.pickerStyle(.menu)
                    }
                }
            }
        }
    }
  }
    

