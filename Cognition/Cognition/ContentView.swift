//
//  ContentView.swift
//  TestAppiOS
//
//  Created by Scott Miller on 11/25/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.menuLabel, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var trainButtonColor: Color = .purple
    
    init() {
        UITableView.appearance().backgroundColor = .white
        UIView.appearance().backgroundColor = .white
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                MainNavigation(items, context: viewContext)
                Spacer()
                HStack { Image("LogoUT"); Spacer(); Image("LogoAeris") }
            }.background(Color.white)
        }.background(Color.white)
    }
}

private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

private let itemStringFormatter: Formatter = {
    return Formatter()
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

