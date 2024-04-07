//
//  PaymentDetailsView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 06/04/24.
//

import SwiftUI

struct PaymentDetailsView: View {
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Text("Payment Details")
                    .font(.title)
                    .bold()
                Spacer()
                Image(systemName: "arrowtriangle.down.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.red)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 20) {
                    Text("Movie tickets")
                        .font(.title2)
                    
                    Spacer()
                    
                    Text("-49.99")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.red)
                }
                
                Text("08 Jul 2024")
                    .font(.subheadline)
                
                Text("Some address to display but with large text")
                    .font(.subheadline)
                    .lineLimit(2)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Memo")
                        .font(.headline)
                        .bold()
                    
                    Text("Some memo info here")
                        .font(.subheadline)
                }
                
                Divider()
            }
            
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PaymentDetailsView()
}
