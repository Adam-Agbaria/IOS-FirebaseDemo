//
//  AfekaFinalApp.swift
//  AfekaFinal
//
//  Created by flash on 18/07/2025.
//

import SwiftUI
import FirebaseCore

@main
struct AfekaFinalApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
