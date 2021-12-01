//
//  AppStatusView.swift
//  BCILab
//
//  Created by Scott Miller on 11/26/21.
//

import Foundation
import SwiftUI

struct StatusRec {
    let imagesCount: Int
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
                    if self.status.imagesCount <= 0 {
                        Text("Images status:").bold().font(.largeTitle).foregroundColor(.black) }
                    Text("Headset status:").bold().font(.largeTitle).foregroundColor(.black)
                    Text("Headset type:").bold().font(.largeTitle).foregroundColor(.black) }
                VStack(alignment: .trailing) {
                    if self.status.imagesCount <= 0 {
                        Text("No images found").bold().font(.largeTitle).foregroundColor(.red) }
                    Text("\(self.status.headsetStatus)").bold().font(.largeTitle).foregroundColor(statusColor)
                    Text("\(self.status.boardName)").bold().font(.title).foregroundColor(.blue) }
            } // HStack
        } // ZStack
    }
}
