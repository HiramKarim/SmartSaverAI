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
    
    enum PaymentCategory: String, Identifiable, CaseIterable {
        var id: Self { self }
        case unspecified = "Unspecified"
        case Bank = "Bank"
        case PersonalAccount = "Personal Account"
        case Other = "Other"
    }
    
    @State private var selectedPaymentCategory: PaymentCategory = .unspecified
    
    var body: some View {
        VStack(spacing: 20) {
            
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
            
            VStack(alignment: .leading) {
                Text("Name")
                    .bold()
                TextField("Enter payment name", text: $paymentName)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading) {
                Text("Type")
                    .bold()
                Picker("", selection: $paymentType) {
                    Text("Income").tag("Income")
                    Text("Expence").tag("Expence")
                }
                .pickerStyle(.segmented)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Category")
                        .bold()
                    
                    Picker("Category", selection: $selectedPaymentCategory) {
                        ForEach(PaymentCategory.allCases) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.leading, -10)
                    .tint(Color.blue)
                }
                
                Spacer()
            }

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
            
            VStack(alignment: .leading) {
                Text("Location (optional)")
                    .bold()
                TextField("Where do you spend?", text: $paymentLocation)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading) {
                Text("Memo")
                    .bold()
                TextField("Your personal note", text: $paymentName)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(action: {
                
            }, label: {
                Text("Save")
            })
            .controlSize(.extraLarge)
            .background(Color.purple)
            .foregroundStyle(Color.white)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AddPaymentView()
}
