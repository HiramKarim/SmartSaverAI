//
//  SmartSavingsMainView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 29/03/24.
//

import SwiftUI
import PersistenceModule

struct SmartSavingsMainView: View {
    @EnvironmentObject var coredataManager: CoreDataManager
    @State private var presentingSheet = false
    
    var mockDataArray: [String] = ["Salary", "Gasoline", "Groceries", "Medicine"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                ScrollView(showsIndicators: false) {
                    BalanceView()
                    TransactionsView()
                }
            }
            .navigationTitle("Personal Finance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "gear")
                            .padding(.horizontal)
                            .foregroundColor(Color.black)
                            .font(.title2)
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        presentingSheet = true
                    }) {
                        Image(systemName: "plus.circle")
                            .padding(.horizontal)
                            .foregroundColor(Color.black)
                            .font(.title2)
                            .bold()
                    }
                    .sheet(isPresented: $presentingSheet, content: {
                        AddPaymentView()
                    })
                }
            }
        }
    }
}

#Preview {
    SmartSavingsMainView()
}
