//
//  ChangeHeadsetTypeView.swift
//  BCILab
//
//  Created by Scott Miller on 10/16/21.
//

import SwiftUI

struct ChangeHeadsetTypeView: View {
    @Binding var boardId: BoardIds

    var body: some View {
        let pickerLabel = Text("").foregroundColor(.black)
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(showsIndicators: true) {
                Picker(selection: self.$boardId, label: pickerLabel) {
                    ForEach(BoardIds.allCases, id: \.self) { value in
                        Text(String(value.name))
                            .font(.title2)
                            .foregroundColor(.black)
                            .tag(value)
                    }
                }.pickerStyle(.radioGroup)
            }
        }
    }
}

