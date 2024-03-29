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
                    
                    VStack {
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
                                .foregroundColor(Color.white)
                                .bold()
                            )
                            .frame(width: 350, height: 200)
                            .padding()
                        }
                        
                        HStack {
                            ViewThatFits(in: .vertical) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.purple)
                                .overlay(
                                    VStack(spacing: 10) {
                                        Text("Income")
                                        Text("$2,771")
                                    }
                                    .foregroundColor(Color.white)
                                    .bold()
                                    .font(.system(size: 30))
                                )
                                .frame(width: 150, height: 130)
                                .padding()
                            }
                            
                            ViewThatFits(in: .vertical) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.orange)
                                .overlay(
                                    VStack(spacing: 10) {
                                        Text("Expense")
                                        Text("$2,771")
                                    }
                                    .foregroundColor(Color.white)
                                    .bold()
                                    .font(.system(size: 30))

                                )
                                .frame(width: 150, height: 130)
                                .padding()
                            }
                        }
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
