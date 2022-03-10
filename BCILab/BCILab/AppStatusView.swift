//
//  AppStatusView.swift
//  BCILab
//
//  Created by Scott Miller on 11/26/21.
//

import Foundation
import SwiftUI

struct AppStatusView: View {
    @ObservedObject var appState: AppState
    var headsetColor: Color {
        (self.appState.headsetStatus == "connected") ? .green : .red
    }
    var imagesColor: Color {
        (self.numImages > 0) ? .green : .red
    }
    var numImages: Int {appState.totalImages/2}
    var numLabels: Int {appState.labels.count}
    var imageCounts: String {
        if self.numImages <= 0 { return "No images found" }
        else { return "\(self.numImages) images and \(self.numLabels) labels" }
    }
    var loadFolder: String {self.appState.loadFolder.lastPathComponent}
    
    var body: some View {
        ZStack {
            Color.white

            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("Image folder:").bold().font(.title2).foregroundColor(.black)
                    Text("Image counts:").bold().font(.title2).foregroundColor(.black)
                    Text("Headset status:").bold().font(.title2).foregroundColor(.black)
                    Text("Headset type:").bold().font(.title2).foregroundColor(.black) }
                VStack(alignment: .trailing) {
                    Text("\(self.loadFolder)").bold().font(.title2).foregroundColor(.green)
                    Text("\(self.imageCounts)").bold().font(.title2).foregroundColor(self.imagesColor)
                    Text("\(self.appState.headsetStatus)").bold().font(.title2).foregroundColor(self.headsetColor)
                    Text("\(self.appState.boardId.name)").bold().font(.title2).foregroundColor(.blue) }
            }
        } // ZStack
    }
}
