//
//  ChangeHeadsetType.swift
//  BCILab
//
//  Created by Scott Miller on 10/16/21.
//

import SwiftUI

struct ChangeHeadsetTypeView: View {
    @ObservedObject var appState: AppState
    let message: String = "Change the headset type"

    var body: some View {
        Spacer()
        Text(message).font(.title)
        ScrollView(showsIndicators: true) {
            Picker(selection: self.$appState.boardId, label: Text("Headset:")) {
                ForEach(BoardIds.allCases, id: \.self) { value in
                    Text(String(value.name)).font(.title).tag(value) }
            }
        }
        .padding()
        Spacer()
    }

//    var body: some View {
//        Text(self.message)
//        Picker("Headset Type", selection: self.$boardId) {
//            ForEach(BoardIds.allCases.first..<BoardIds.allCases.last) { id in
//                Text(String(id) }}
//    }
}

