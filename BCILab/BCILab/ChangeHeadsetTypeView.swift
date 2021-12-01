//
//  ChangeHeadsetType.swift
//  BCILab
//
//  Created by Scott Miller on 10/16/21.
//

import SwiftUI

struct ChangeHeadsetTypeView: View {
    @Binding var boardId: BoardIds
    //@ObservedObject var appState: AppState
    let message: String = "Change the headset type"

    var body: some View {
        Spacer()
        Text(message).font(.title).foregroundColor(.black)
        ScrollView(showsIndicators: true) {
            Picker(selection: self.$boardId, label: Text("Headset:").foregroundColor(.black)) {
                ForEach(BoardIds.allCases, id: \.self) { value in
                    Text(String(value.name))
                        .font(.title)
                        .foregroundColor(.black)
                        .tag(value) }
            }.pickerStyle(.automatic)

        }
        .padding(.all)
        Spacer()
    }

//    var body: some View {
//        Text(self.message)
//        Picker("Headset Type", selection: self.$boardId) {
//            ForEach(BoardIds.allCases.first..<BoardIds.allCases.last) { id in
//                Text(String(id) }}
//    }
}

