import SwiftUI

struct ContentView: View {
    #if os(iOS)
    init() {
        UITableView.appearance().backgroundColor = .white // for NavigationView background
    }
    #endif
    
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
