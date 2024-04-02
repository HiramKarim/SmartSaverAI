//
//  AddPaymentView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 01/04/24.
//

import SwiftUI

struct AddPaymentView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var paymentName: String = ""
    @State var paymentType: String = "Income"
    @State var paymentDate: Date = Date()
    @State var paymentAmount: String = ""
    @State var paymentLocation: String = ""
    @State var paymentMemo: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("New Payment")
                    .bold()
                    .font(.system(size: 30))
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.red)
                }

            }
            .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundStyle(Color.red)
                        Text("Please enter the payment name")
                    }
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundStyle(Color.red)
                        Text("Please enter a valid amount")
                    }
                }
                
                Spacer()
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("Name")
                    .bold()
                TextField("Enter payment name", text: $paymentName)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("Type")
                    .bold()
                Picker("", selection: $paymentType) {
                    Text("Income").tag("Income")
                    Text("Expence").tag("Expence")
                }
                .pickerStyle(.segmented)
            }
            .padding()
            
            HStack() {
                VStack {
                    Text("Date")
                        .bold()
                    DatePicker("Today",
                               selection: $paymentDate,
                               displayedComponents: .date)
                    .labelsHidden()
                    .padding(.horizontal)
                }
                
                VStack {
                    Text("Amount($)")
                        .bold()
                    TextField("0.0", text: $paymentAmount)
                        .textFieldStyle(.roundedBorder)
                }
                
                
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("Location (optional)")
                    .bold()
                TextField("Where do you spend?", text: $paymentLocation)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("Memo")
                    .bold()
                TextField("Your personal note", text: $paymentName)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            
            Button(action: {
                
            }, label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
            })
            .controlSize(.extraLarge)
            .background(Color.purple)
            .foregroundStyle(Color.white)
            .frame(height: 50)
            
            Spacer()
        }
    }
}

#Preview {
    AddPaymentView()
}
