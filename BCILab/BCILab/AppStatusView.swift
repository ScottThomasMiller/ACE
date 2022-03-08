//
//  AppStatusView.swift
//  BCILab
//
//  Created by Scott Miller on 11/26/21.
//

import Foundation
import SwiftUI

struct StatusRec {
    let numImages: Int
    let numLabels: Int
    let headsetStatus: String
    let boardName: String
    let loadFolder: String
}

struct AppStatusView: View {
    let status: StatusRec
    var statusColor: Color = .red

    init (_ status: StatusRec) {
        self.status = status
        self.statusColor = (status.headsetStatus == "connected") ? .green : .red
    }

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
                    Text("\(self.status.loadFolder)").bold().font(.title2).foregroundColor(.green)
                    if self.status.numImages <= 0 {
                        Text("No images found").bold().font(.title2).foregroundColor(.red) }
                    else {
                        Text("\(self.status.numImages) images and \(self.status.numLabels) labels").bold().font(.title2).foregroundColor(.green) }
                    Text("\(self.status.headsetStatus)").bold().font(.title2).foregroundColor(statusColor)
                    Text("\(self.status.boardName)").bold().font(.title2).foregroundColor(.blue) }
            } // HStack
        } // ZStack
    }
}
