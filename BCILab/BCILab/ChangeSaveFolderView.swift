//
//  ChangeSaveFolder.swift
//  BCILab
//
//  Created by Scott Miller on 9/26/21.
//
//

import SwiftUI

struct FolderPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIDocumentPickerViewController

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        //picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
}

struct ChangeSaveFolderView: View {
    let message: String 
    @ObservedObject var appState: AppState
    let folderPicker = FolderPicker()
    @State private var isActive: Bool = true

    func onDismiss() {
        self.isActive = false
    }
    
    var body: some View {
        folderPicker
    }
}
    

