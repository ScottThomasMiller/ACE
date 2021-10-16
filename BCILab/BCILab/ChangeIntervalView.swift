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
    @State var intervalString = ""
    
    init(message: String, appState: AppState) {
        self.message = message
        self.appState = appState
        self.intervalString = self.appState.intervalSeconds
    }
    
    var body: some View {
        Text("Enter the new animation interval seconds:")
        VStack(alignment: .leading) {
              TextField("Enter interval seconds...", text: $intervalString, onEditingChanged: {
                  (changed) in self.appState.intervalSeconds = intervalString }) {
                        print("Username onCommit") }
        }.fixedSize()
         .padding()
        
//        TextField(message, text: $intervalString)
//            .disableAutocorrection(true)
//            .border(Color(UIColor.separator))
    }
}

//struct ChangeIntervalView_Previews: PreviewProvider {
//    static var previews: some View {
//        let appState = AppState()
//        ChangeIntervalView(message: "Vegas Baby!", appState: appState)
//    }
//}
