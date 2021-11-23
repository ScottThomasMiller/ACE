//
//  ChangeSaveFolder.swift
//  BCILab
//
//  Created by Scott Miller on 9/26/21.
//
//

import UIKit
import SwiftUI
import Foundation

struct FolderPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let newVC = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        //newVC.delegate = self
        return newVC
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
    
//class FolderPicker: UIDocumentPickerViewController, UIDocumentPickerDelegate {
    typealias UIViewControllerType = UIDocumentPickerViewController

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let folderChoice = urls.first { controller.directoryURL = folderChoice }
        controller.dismiss(animated: true)
    }
}

struct ChangeSaveFolderView: View {
    let message: String 
    @ObservedObject var appState: AppState
    @State private var isActive: Bool = true
    let picker = FolderPicker()
    

    func onDismiss() {
        self.isActive = false
    }
    
    var body: some View {
        Text("hello")
    }
}
    

