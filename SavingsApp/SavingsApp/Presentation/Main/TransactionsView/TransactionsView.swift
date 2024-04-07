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
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Recent transactions")
                    .font(.title2)
                    .foregroundStyle(Color.gray)
                
                HStack {
                    Button("All") {
                        
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    
                    Button("Income") {
                        
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                    
                    Button("Expence") {
                        
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                    
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
                        Text("+ $20,000")
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
