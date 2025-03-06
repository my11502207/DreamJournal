//
//  DreamJournalApp.swift
//  DreamJournal
//
//  Created by kevin on 2025/3/6.
//

import SwiftUI
import SwiftData

@main
struct dreamjournalApp: App {
    @StateObject private var dreamStore = DreamStore()
        @State private var selectedTab = 0
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
                      .environmentObject(dreamStore)
                      .tabItem {
                          Label("首页", systemImage: "house.fill")
                      }
                      .tag(0)
                  
                  DreamHistoryView()
                      .environmentObject(dreamStore)
                      .tabItem {
                          Label("历史", systemImage: "calendar")
                      }
                      .tag(1)
                  
                  DreamAnalysisView()
                      .environmentObject(dreamStore)
                      .tabItem {
                          Label("分析", systemImage: "chart.pie.fill")
                      }
                      .tag(2)
              }
              .accentColor(Color("AccentColor"))
              .preferredColorScheme(.dark)
          }
          .modelContainer(sharedModelContainer)
      }
}
