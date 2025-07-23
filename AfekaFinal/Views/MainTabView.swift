import SwiftUI

struct MainTabView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView {
            BillCalculatorView()
                .tabItem {
                    Image(systemName: "calculator")
                    Text("מחשבון")
                }
                .tag(0)
            
            BillHistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("היסטוריה")
                }
                .tag(1)
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("סטטיסטיקות")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .preferredColorScheme(colorScheme)
        .onAppear {
            setupAppearance()
        }
    }
    
    private func setupAppearance() {
        // Configure tab bar appearance for better dark mode support
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        if colorScheme == .dark {
            tabBarAppearance.backgroundColor = UIColor.systemBackground
        } else {
            tabBarAppearance.backgroundColor = UIColor.systemBackground
        }
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

#Preview {
    MainTabView()
} 