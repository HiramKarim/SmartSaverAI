//
//  TransactionsView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 29/03/24.
//

import SwiftUI

struct TransactionsView: View {
    
    var mockDataArray: [String] = ["Salary", "Gasoline", "Groceries", "Medicine"]
    
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
            .padding()
            
            LazyVStack {
                ForEach(mockDataArray, id: \.self) { data in
                    HStack() {
                        Image(systemName: "arrowtriangle.up.circle")
                        VStack {
                            Text(data)
                        }
                        Spacer()
                        Text("+ $20,000")
                    }
                    .frame(width: 200, height: 50)
                    .padding(.horizontal)
                    .background(Color.red)
                }
            }
        }
        .padding(.leading, 15)
    }
}

#Preview {
    TransactionsView()
}
