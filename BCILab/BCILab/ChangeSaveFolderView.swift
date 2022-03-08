//
//  ChangeSaveFolder.swift
//  BCILab
//
//  Created by Scott Miller on 9/26/21.
//
//

//import UIKit
import SwiftUI
import Foundation

//struct FolderPicker: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let newVC = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
//        //newVC.delegate = self
//        return newVC
//    }
//
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
//    }
//
//    typealias UIViewControllerType = UIDocumentPickerViewController
//
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        if let folderChoice = urls.first { controller.directoryURL = folderChoice }
//        controller.dismiss(animated: true)
//    }
//}
//
struct ChangeSaveFolderView: View {
    @Binding var saveFolderURL: URL

    func pickFolder() {
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
    

