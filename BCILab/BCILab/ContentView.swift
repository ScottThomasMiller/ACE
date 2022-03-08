import SwiftUI

// TabView timer code forked from: https://stackoverflow.com/questions/58896661/swiftui-create-image-slider-with-dots-as-indicators

struct ContentView: View {
    
    var body: some View {
        let _ = try? BoardShim.logMessage(.LEVEL_INFO, "ContentView body recompute")
        Experiment()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
