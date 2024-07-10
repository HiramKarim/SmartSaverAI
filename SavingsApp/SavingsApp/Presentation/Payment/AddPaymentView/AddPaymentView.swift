//
//  AddPaymentView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 01/04/24.
//

import SwiftUI
import Combine

struct AddPaymentView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var vm = RegisterPaymentVM(registerPaymentUseCase: RegisterPaymentUseCase())
    @ObservedObject private var updateVM = UpdatePaymentVM(useCase: UpdatePaymentUseCase())
    
    @Binding var dataSaved: PassthroughSubject<Void, Never>
    var paymentRegistryDTO: PaymentRegistryDTO
    
    var paymentViewState: PaymentViewState = .insert
    
    @Binding var navPath: [String]
    
    @Binding var shouldRefreshDetailView: PassthroughSubject<Void, Never>
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
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
                    TextField("Enter payment name", text: $vm.paymentName)
                        .textFieldStyle(.roundedBorder)
                }
                
                //MARK: - Type Section
                VStack(alignment: .leading) {
                    Text("Type")
                        .bold()
                    Picker("", selection: $vm.paymentType) {
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
                        
                        Picker("Category", selection: $vm.selectedPaymentCategory) {
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
                                   selection: $vm.paymentDate,
                                   displayedComponents: .date)
                        .labelsHidden()
                        .padding(.horizontal)
                    }
                    
                    VStack {
                        Text("Amount($)")
                            .bold()
                        TextField("0.0", text: $vm.paymentAmount)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                //MARK: - Location Section
                VStack(alignment: .leading) {
                    Text("Location (optional)")
                        .bold()
                    TextField("Where do you spend?", text: $vm.paymentLocation)
                        .textFieldStyle(.roundedBorder)
                }
                
                //MARK: - Memo Section
                VStack(alignment: .leading) {
                    Text("Memo")
                        .bold()
                    TextField("Your personal note", text: $vm.paymentMemo)
                        .textFieldStyle(.roundedBorder)
                }
                
                //MARK: - Button Action Section
                Button(action: {
                    if paymentViewState == .update {
                        updateVM.updatePaymentRegistry(payment: vm.getUpdatedPaymentRegistryDTO())
                    } else {
                        vm.registerPayment()
                    }
                }, label: {
                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .foregroundStyle(Color.white)
                    } else if vm.showSuccessRegistry {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.white)
                        Text("Success")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                    } else if vm.showErrorOnRegistry {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(Color.red)
                        Text("Error")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                    } else {
                        Text("Save")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                    }
                })
                .padding()
                .frame(maxWidth: .infinity)
                .background(vm.isLoading || vm.showSuccessRegistry ? Color.green : Color.purple, in: Capsule())
                .opacity(vm.showSuccessRegistry ? 0.8 : 1.0)
                .disabled(vm.isLoading)
                .controlSize(.large)
                
                
                Spacer()
            }
            .navigationTitle(paymentViewState == .insert ?
                             "New Payment" :
                                "Update Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                if paymentViewState == .update {
                    vm.updateViewForUpdate(paymentRegistry: paymentRegistryDTO)
                }
            }
            .onReceive(vm.savedRegistrySuccessSubject, perform: { _ in
                self.dataSaved.send()
            })
            .onChange(of: vm.showSuccessRegistry, {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1,
                                              execute: {
                    vm.isLoading = false
                    vm.showSuccessRegistry = false
                    vm.showErrorOnRegistry = false
                })
            })
            .onChange(of: vm.showErrorOnRegistry, {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1,
                                              execute: {
                    vm.showSuccessRegistry = false
                    vm.showErrorOnRegistry = false
                })
            })
            .onChange(of: updateVM.paymentUpdated, {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1,
                                              execute: {
                    vm.isLoading = false
                    vm.showSuccessRegistry = false
                    vm.showErrorOnRegistry = false
                    shouldRefreshDetailView.send()
                    self.dismiss()
                })
            })
            .onChange(of: updateVM.showError, {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1,
                                              execute: {
                    vm.showSuccessRegistry = false
                    vm.showErrorOnRegistry = false
                })
            })
            .padding()
        }
    }
}


#Preview {
    AddPaymentView(
        dataSaved: .constant(PassthroughSubject<Void, Never>()),
        paymentRegistryDTO: PaymentRegistryDTO(),
        paymentViewState: .insert,
        navPath: .constant([""]), 
        shouldRefreshDetailView: .constant(PassthroughSubject<Void, Never>())
    )
}
