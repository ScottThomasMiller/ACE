//
//  ChangeIntervalView.swift
//  BCILab
//
//  Created by Scott Miller on 10/10/21.
//

import SwiftUI

struct ChangeIntervalView: View {
    @Binding var intervalSeconds: Double
    //@Binding var isMainMenuActive: Bool
    @State private var newValue: Double = 0.0

    var body: some View {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
        
        HStack {
            Text("Slideshow interval:")
            TextField("interval seconds", value: self.$newValue, formatter: formatter, onCommit: {
                self.intervalSeconds = self.newValue
                try? BoardShim.logMessage(.LEVEL_INFO, "new interval: \(intervalSeconds) sec.")
            })
            .fixedSize(horizontal: true, vertical: true)
            .padding()
            Text("seconds")
        }
        .font(.title2)
        .foregroundColor(.black)
        .onAppear(perform: {self.newValue = self.intervalSeconds})
    }
}

