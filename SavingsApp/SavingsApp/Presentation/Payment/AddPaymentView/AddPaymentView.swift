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
        case Bank = "Bank"
        case PersonalAccount = "Personal Account"
        case Other = "Other"
    }
    
    @State private var selectedPaymentCategory: PaymentCategory = .Other
    
    var body: some View {
        VStack(spacing: 20) {
            
            //MARK: - New Payment header section
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
            
            //MARK: - Alerts section
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
            
            //MARK: - Name Section
            VStack(alignment: .leading) {
                Text("Name")
                    .bold()
                TextField("Enter payment name", text: $paymentName)
                    .textFieldStyle(.roundedBorder)
            }
            
            //MARK: - Type Section
            VStack(alignment: .leading) {
                Text("Type")
                    .bold()
                Picker("", selection: $paymentType) {
                    Text("Income").tag("Income")
                    Text("Expence").tag("Expence")
                }
                .pickerStyle(.segmented)
            }
            
            //MARK: - Category Section
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

            //MARK: - Date and amount Section
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
            
            //MARK: - Location Section
            VStack(alignment: .leading) {
                Text("Location (optional)")
                    .bold()
                TextField("Where do you spend?", text: $paymentLocation)
                    .textFieldStyle(.roundedBorder)
            }
            
            //MARK: - Memo Section
            VStack(alignment: .leading) {
                Text("Memo")
                    .bold()
                TextField("Your personal note", text: $paymentName)
                    .textFieldStyle(.roundedBorder)
            }
            
            //MARK: - Button Action Section
            Button(action: {
                
            }, label: {
                Text("Save")
                    .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .foregroundStyle(Color.white)
                    .background(Color.purple, in: Capsule())
            })
            .frame(width: 200)
            
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AddPaymentView()
}
