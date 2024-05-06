//
//  PaymentDetailsView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 06/04/24.
//

import SwiftUI
import Combine

struct PaymentDetailsView: View {
    
    @Binding var paymentTransactionSubject: PaymentRegistryDTO
    
    @ObservedObject var paymentDetailsVM = PaymentDetailsVM()
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Text("Payment Details")
                    .font(.title)
                    .bold()
                Spacer()
                Image(systemName: paymentDetailsVM.paymentType == 2 ? "arrowtriangle.down.circle.fill" : "arrowtriangle.up.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(paymentDetailsVM.paymentType == 2 ? Color.red : Color.green)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 20) {
                    Text(paymentDetailsVM.name)
                        .font(.title2)
                    
                    Spacer()
                    
                    Text(paymentDetailsVM.paymentType == 2 ? "-\(paymentDetailsVM.amount, specifier: "%.2f")" : "\(paymentDetailsVM.amount, specifier: "%.2f")")
                        .font(.title)
                        .bold()
                        .foregroundStyle(paymentDetailsVM.paymentType == 2 ? Color.red : Color.green)
                }
                
                Text(paymentDetailsVM.date.convertToString(withFormat: .fullDate))
                    .font(.subheadline)
                
                Text(paymentDetailsVM.location)
                    .font(.subheadline)
                    .lineLimit(2)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Memo")
                        .font(.headline)
                        .bold()
                    
                    Text(paymentDetailsVM.memo)
                        .font(.subheadline)
                }
                
                Divider()
            }
            
            
            Spacer()
        }
        .padding()
        .onAppear(perform: {
            self.paymentDetailsVM.updateView(withPayment: paymentTransactionSubject)
        })
    }
}

#Preview {
    PaymentDetailsView(paymentTransactionSubject: .constant(PaymentRegistryDTO()))
}
