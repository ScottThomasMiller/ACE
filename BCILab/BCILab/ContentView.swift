import SwiftUI

// TabView timer code forked from: https://stackoverflow.com/questions/58896661/swiftui-create-image-slider-with-dots-as-indicators

struct ContentView: View {
    @StateObject var appState = AppState()
    
    var body: some View {
        ExperimentVC(appState: self.appState)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
