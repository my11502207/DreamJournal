//
//  DreamJournalApp.swift
//  DreamJournal
//

import SwiftUI
import SwiftData

@main
struct dreamjournalApp: App {
    @State private var selectedTab = 0
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Dream.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("首页", systemImage: "house.fill")
                    }
                    .tag(0)
                
                ProfileView()
                    .tabItem {
                        Label("我的", systemImage: "person.fill")
                    }
                    .tag(1)
            }
            .accentColor(Color("AccentColor"))
            .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
