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
        Text("Enter the new slideshow interval seconds:").foregroundColor(.black)
//        TextField("interval seconds", value: self.$intervalSeconds, formatter: formatter, onCommit: {
        TextField("interval seconds", value: self.$newValue, formatter: formatter, onCommit: {
            self.intervalSeconds = self.newValue
            try? BoardShim.logMessage(.LEVEL_INFO, "new interval: \(intervalSeconds) sec.")
            //self.isMainMenuActive = false
        })
        .foregroundColor(.black)
        .fixedSize(horizontal: true, vertical: true)
        .padding()
        .border(.blue, width: 2)
        
    }
}

