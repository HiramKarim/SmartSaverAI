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
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                ScrollView {
                    
                    ViewThatFits(in: .vertical) {
                        RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue)
                        .overlay(
                            VStack(spacing: 20) {
                                Text("Total Balance")
                                    .font(.system(size: 30))
                                Text("$2,771")
                                    .font(.system(size: 70))
                            }
                            .padding(.top, 10)
                            .foregroundColor(Color.white)
                            .bold()
                        )
                        .frame(width: 350, height: 200)
                        .padding()
                    }
                    
                    
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
                        
                    }) {
                        Image(systemName: "plus.circle")
                            .padding(.horizontal)
                            .foregroundColor(Color.black)
                            .font(.title2)
                            .bold()
                    }
                }
            }
        }
    }
}

#Preview {
    SmartSavingsMainView()
}
