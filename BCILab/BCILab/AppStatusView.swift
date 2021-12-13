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
                    Text("Images status:").bold().font(.largeTitle).foregroundColor(.black)
                    Text("Headset status:").bold().font(.largeTitle).foregroundColor(.black)
                    Text("Headset type:").bold().font(.largeTitle).foregroundColor(.black) }
                VStack(alignment: .trailing) {
                    if self.status.numImages <= 0 {
                        Text("No images found").bold().font(.largeTitle).foregroundColor(.red) }
                    else {
                        Text("\(self.status.numImages) images and \(self.status.numLabels) labels").bold().font(.largeTitle).foregroundColor(.green) }
                    Text("\(self.status.headsetStatus)").bold().font(.largeTitle).foregroundColor(statusColor)
                    Text("\(self.status.boardName)").bold().font(.title).foregroundColor(.blue) }
            } // HStack
        } // ZStack
    }
}
