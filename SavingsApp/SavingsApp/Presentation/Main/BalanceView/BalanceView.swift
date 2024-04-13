//
//  BalanceView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 29/03/24.
//

import SwiftUI

struct BalanceView: View {
    var body: some View {
        VStack {
            ViewThatFits(in: .vertical) {
                RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue)
                .overlay(
                    VStack(spacing: 20) {
                        Text("Total Balance")
                            .font(.system(size: 30))
                        Text("$0")
                            .font(.system(size: 70))
                    }
                    .foregroundColor(Color.white)
                    .bold()
                )
                .frame(width: 350, height: 200)
            }
            .padding()
            
            HStack {
                ViewThatFits(in: .vertical) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.purple)
                    .overlay(
                        VStack(spacing: 10) {
                            Text("Income")
                            Text("$0")
                        }
                        .foregroundColor(Color.white)
                        .bold()
                        .font(.system(size: 30))
                    )
                    .frame(width: 150, height: 130)
                }
                .padding()
                
                ViewThatFits(in: .vertical) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange)
                    .overlay(
                        VStack(spacing: 10) {
                            Text("Expense")
                            Text("$0")
                        }
                        .foregroundColor(Color.white)
                        .bold()
                        .font(.system(size: 30))

                    )
                    .frame(width: 150, height: 130)
                }
                .padding()
            }
        }
        
    }
}

#Preview {
    BalanceView()
}
