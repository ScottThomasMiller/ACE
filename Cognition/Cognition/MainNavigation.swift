//
//  MainNavigation.swift
//  Cognition
//
//  Created by Scott Miller on 11/27/22.
//

import Foundation
import SwiftUI
import CoreData

//struct MainNavigation<item: Comparable & Identifiable>: View {
struct MainNavigation: View {
    private var items: FetchedResults<Item>
    private let viewContext: NSManagedObjectContext

    init(_ items: FetchedResults<Item>, context: NSManagedObjectContext) {
        self.items = items
        self.viewContext = context
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("\(item.menuLabel!)").font(.title)
                        } label: {
                            Text("\(item.menuLabel!)").font(.title)
                        }
                    }
                    .onDelete(perform: deleteItems)
                    .background(Color.white)
                }.background(Color.white)
                    .navigationBarHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                        ToolbarItem {
                            Button(action: addItem) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                    }
//                Text("Select an item")
            }
        }.background(Color.white)
    }
}

