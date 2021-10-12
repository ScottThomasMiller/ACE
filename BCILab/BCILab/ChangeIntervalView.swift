//
//  ChangeIntervalView.swift
//  BCILab
//
//  Created by Scott Miller on 10/10/21.
//

import SwiftUI

struct ChangeIntervalView: View {
    let message: String
    @ObservedObject var appState: AppState

    var body: some View {
        Color(.white)
        Text("change animation interval happens now")
    }
}

//struct ChangeIntervalView_Previews: PreviewProvider {
//    static var previews: some View {
//        let appState = AppState()
//        ChangeIntervalView(message: "Vegas Baby!", appState: appState)
//    }
//}
