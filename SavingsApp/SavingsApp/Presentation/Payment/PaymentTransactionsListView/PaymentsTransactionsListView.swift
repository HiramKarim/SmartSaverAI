//
//  TransactionsView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 29/03/24.
//

import SwiftUI

struct PaymentsTransactionsListView: View {
    
    @ObservedObject private var vm = FetchPaymentByDateVM(fetchPaymentsByDateUseCase: FetchPaymentByDate())
    
    @Binding var presentPaymentDetail: Bool
    
    @State private var allButton:Bool = true
    @State private var incomeButton:Bool = false
    @State private var expenceButton:Bool = false
    
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
            
            LazyVStack(spacing: 10) {
                ForEach($vm.dataPaymentArray, id: \.self) { payment in
                    HStack(spacing: 10) {
                        Image(systemName: payment.typeNum.wrappedValue == 2 ? "arrowtriangle.down.circle" : "arrowtriangle.up.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(payment.typeNum.wrappedValue == 2 ? Color.red : Color.green)
                        VStack(alignment: .leading, spacing: 10) {
                            Text(payment.name.wrappedValue)
                                .lineLimit(2)
                                .font(.callout)
                            Text(payment.date.wrappedValue.convertToString(withFormat: .fullDate))
                                .font(.callout)
                                .foregroundStyle(Color.gray)
                        }
                        .padding()
                        Spacer()
                        Text("\(payment.amount.wrappedValue, specifier: "%.2f")")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .background(RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color.init("low-blue", bundle: nil)))
                    .onTapGesture {
                        presentPaymentDetail = true
                    }
                }
            }
        }
        .onAppear(perform: {
            vm.fetchPayments(forMonth: 5, year: 2024, limit: nil)
        })
        .padding()
    }
}

#Preview {
    PaymentsTransactionsListView(presentPaymentDetail: .constant(true))
}
