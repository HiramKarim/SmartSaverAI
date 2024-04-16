//
//  TransactionsView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 29/03/24.
//

import SwiftUI

struct TransactionsView: View {
    
    var mockDataArray: [String] = ["Salary", "Gasoline", "Groceries", "Medicine"]
    @Binding var presentPaymentDetail: Bool
    
    @State private var allButton:Bool = true
    @State private var incomeButton:Bool = false
    @State private var expenceButton:Bool = false
    
    private func handleButtonsColor(buttonState:Bool) {
        
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Recent transactions")
                    .font(.title2)
                    .foregroundStyle(Color.gray)
                
                HStack {
                    Button("All") {
                        allButton = true
                        incomeButton = false
                        expenceButton = false
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(allButton ? .purple : .gray)
                    
                    Button("Income") {
                        allButton = false
                        incomeButton = true
                        expenceButton = false
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(incomeButton ? .purple : .gray)
                    
                    Button("Expence") {
                        allButton = false
                        incomeButton = false
                        expenceButton = true
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(expenceButton ? .purple : .gray)
                    
                    Spacer()

                }
                
            }
            .padding(.leading, 0)
            .padding(.bottom, 10)
            
            LazyVStack(spacing: 20) {
                ForEach(mockDataArray, id: \.self) { data in
                    HStack(spacing: 20) {
                        Image(systemName: "arrowtriangle.up.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading, spacing: 10) {
                            Text(data)
                                .font(.headline)
                            Text("Yesterday, 4:15 pm")
                                .font(.callout)
                                .foregroundStyle(Color.gray)
                        }
                        .padding()
                        Spacer()
                        Text("$0")
                            .font(.headline)
                    }
                    .padding()
                    .frame(width: .infinity, height: 80)
                    .background(RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color.init("low-blue", bundle: nil)))
                    .onTapGesture {
                        presentPaymentDetail = true
                    }
                }
            }
            .frame(width: .infinity)
        }
        .padding()
    }
}

#Preview {
    TransactionsView(presentPaymentDetail: .constant(true))
}
