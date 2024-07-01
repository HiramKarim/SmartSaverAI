//
//  AppState.swift
//  SavingsApp
//
//  Created by Hiram Castro on 30/06/24.
//

import SwiftUI

class AppState: ObservableObject {
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
}
