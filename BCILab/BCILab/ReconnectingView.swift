//
//  ReconnectingView.swift
//  BCILab
//
//  Created by Scott Miller on 4/2/22.
//

import Foundation
import SwiftUI
import BrainFlow

struct ReconnectingView: View {
    @Binding var boardId: BoardIds
    @Binding var headset: Headset

    var body: some View {
        let pickerLabel = Text("").foregroundColor(.black)
        ZStack {
            Color.white
        
            VStack(alignment: .leading, spacing: 10) {
                ScrollView(showsIndicators: true) {
                    Picker(selection: self.$boardId, label: pickerLabel) {
                        ForEach(BoardIds.allCases, id: \.self) { value in
                            Text(String(value.name))
                                .font(.title2)
                                .foregroundColor(.black)
                                .tag(value)
                        }
    //                }.pickerStyle(.radioGroup)
                    }.pickerStyle(.automatic)
                }
            }.onChange(of: self.boardId, perform: { _ in self.headset.isActive = false })
        }
    }
}
