//
//  SavingsAppApp.swift
//  SavingsApp
//
//  Created by Hiram Castro on 28/03/24.
//

import SwiftUI

@main
struct SavingsAppApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
    
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.hasCompletedOnboarding {
            SmartSavingsMainView()
        } else {
            OnboardingCarouselView()
        }
    }
}
