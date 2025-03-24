//
//  DreamJournalApp.swift
//  DreamJournal
//

import SwiftUI
import SwiftData

@main
struct dreamjournalApp: App {
    @State private var selectedTab = 0
    @StateObject private var securityService = AppSecurityService()
    @Environment(\.scenePhase) private var scenePhase
    
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
            ZStack {
                // 主应用内容
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
                
                // 如果应用处于锁定状态，显示锁屏视图
                if securityService.isSecurityEnabled && !securityService.isAppUnlocked {
                    AppLockScreenView()
                        .zIndex(1) // 确保锁屏在最上层
                        .transition(.opacity)
                        .animation(.easeInOut, value: securityService.isAppUnlocked)
                }
            }
            .environmentObject(securityService)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // 应用变为活跃状态，可能需要解锁
                // 不直接在这里解锁，因为这可能会导致锁屏UI闪烁
                break
            case .inactive:
                // 应用变为非活跃状态，不需处理
                break
            case .background:
                // 应用进入后台，锁定应用
                securityService.lockApp()
            @unknown default:
                break
            }
        }
    }
}
