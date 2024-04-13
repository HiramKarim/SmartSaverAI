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
            
            LazyVStack {
                ForEach(mockDataArray, id: \.self) { data in
                    HStack() {
                        Image(systemName: "arrowtriangle.up.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                        VStack {
                            Text(data)
                        }
                        Spacer()
                        Text("$0")
                    }
                    .frame(width: .infinity, height: 50)
                    .onTapGesture {
                        presentPaymentDetail = true
                    }
                    
                    Divider()
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
