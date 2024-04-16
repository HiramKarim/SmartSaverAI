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
                .fill(Color.init("low-blue", bundle: nil))
                .overlay(
                    VStack(spacing: 20) {
                        Text("Total Balance")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.gray)
                        Text("$0")
                            .font(.system(size: 70))
                            .foregroundStyle(Color.init("black-color", bundle: nil))
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
                        .fill(Color.init("light-brown-color", bundle: nil))
                    .overlay(
                        VStack(spacing: 10) {
                            Text("Income")
                                .foregroundStyle(Color.gray)
                            Text("$0")
                                .foregroundStyle(Color.init("black-color", bundle: nil))
                        }
                        .bold()
                        .font(.system(size: 30))
                    )
                    .frame(width: 150, height: 130)
                }
                .padding()
                
                ViewThatFits(in: .vertical) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.init("light-brown-color", bundle: nil))
                    .overlay(
                        VStack(spacing: 10) {
                            Text("Expense")
                                .foregroundStyle(Color.gray)
                            Text("$0")
                                .foregroundStyle(Color.init("black-color", bundle: nil))
                        }
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
