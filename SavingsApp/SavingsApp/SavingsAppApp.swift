//
//  SavingsAppApp.swift
//  SavingsApp
//
//  Created by Hiram Castro on 28/03/24.
//

import SwiftUI
import PersistenceModule

@main
struct SavingsAppApp: App {
    
   @StateObject var coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            SmartSavingsMainView()
                .environmentObject(coreDataManager)
        }
    }
}
