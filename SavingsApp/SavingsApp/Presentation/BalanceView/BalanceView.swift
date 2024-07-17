//
//  BalanceView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 29/03/24.
//

import SwiftUI

struct BalanceView: View {
    
    @Binding var totalBalance: Double
    @Binding var totalIncome: Double
    @Binding var totalExpence: Double
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Total Balance")
                    .foregroundStyle(Color.gray)
                    .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 20))
                
                Text("$\(totalBalance, specifier: "%.2f")")
                    .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 40))
                    .lineLimit(1)
                    .minimumScaleFactor(1)
                
                HStack {
                    VStack(alignment:.leading, spacing: 20) {
                        Text("Income")
                            .foregroundStyle(Color.gray)
                            .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 20))
                        
                        Text("$\(totalIncome, specifier: "%.2f")")
                            .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 25))
                            .lineLimit(1)
                            .minimumScaleFactor(1)
                    } //incomes
                    Spacer()
                    VStack(alignment:.leading, spacing: 20) {
                        Text("Expenses")
                            .foregroundStyle(Color.gray)
                            .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 20))
                        
                        Text("$\(totalExpence, specifier: "%.2f")")
                            .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 25))
                            .lineLimit(1)
                            .minimumScaleFactor(1)
                    } //expenses
                } //incomes/expenses stack
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
        }
    }
}

#Preview {
    BalanceView(totalBalance: .constant(10000),
                totalIncome: .constant(120423),
                totalExpence: .constant(159023))
}
