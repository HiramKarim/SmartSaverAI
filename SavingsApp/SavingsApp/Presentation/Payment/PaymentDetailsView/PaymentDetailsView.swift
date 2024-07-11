//
//  PaymentDetailsView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 06/04/24.
//

import SwiftUI
import Combine

struct PaymentDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var paymentRegistryDTO: PaymentRegistryDTO
    @Binding var shouldRefreshListEvent: PassthroughSubject<Void, Never>
    
    @State private var showDeleteAlert = false
    @State private var showUpdate = false
    
    @ObservedObject var paymentDetailsVM = PaymentDetailsVM(deleteUseCase: DeletePaymentUseCase(),
                                                            fetchByNameUseCase: FetchPaymentByNameUseCase())
    
    @Binding var navPath: [String]
    
    @State var shouldRefreshDetailView = PassthroughSubject<Void, Never>()
    
    var body: some View {
        ZStack {
            VStack {
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    HStack(spacing: 10) {
                        Text(paymentDetailsVM.name)
                            .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 20))
                        
                        Spacer()
                        
                        HStack(spacing: 10) {
                            Text(paymentDetailsVM.paymentType == 2 ?
                                 "-$\(paymentDetailsVM.amount, specifier: "%.2f")" :
                                    "$\(paymentDetailsVM.amount, specifier: "%.2f")")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(paymentDetailsVM.paymentType == 2 ?
                                                 Color.red :
                                                    Color.green)
                            Image(systemName: paymentDetailsVM.paymentType == 2 ?
                                  "arrowtriangle.down.circle.fill" :
                                    "arrowtriangle.up.circle.fill"
                            )
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(paymentDetailsVM.paymentType == 2 ?
                                                 Color.red :
                                                    Color.green)
                        }
                        
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
                    
                    //MARK: - Button Action Section
                    HStack {
                        
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Text("Delete")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth:.infinity)
                        .background(Color.red)
                        .background(in: Capsule())
                        
                        
                        
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete Payment"),
                                message: Text("Are you sure you want to delete this payment?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    paymentDetailsVM.deletePayment()
                                    shouldRefreshListEvent.send()
                                    navPath.removeAll()
                                    dismiss()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            //startTimeForUpdateSheet()
                            showUpdate = true
                        }) {
                            Text("Update")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth:.infinity)
                        .background(Color.blue)
                        .background(in: Capsule())
                        .sheet(isPresented: $showUpdate) {
                            AddPaymentView(
                                dataSaved: $shouldRefreshListEvent,
                                paymentRegistryDTO: paymentRegistryDTO,
                                paymentViewState: .update,
                                navPath: $navPath, 
                                shouldRefreshDetailView: $shouldRefreshDetailView
                            )
                        }
                        
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Payment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear(perform: {
                self.paymentDetailsVM.updateView(withPayment: paymentRegistryDTO)
            })
            .onChange(of: paymentDetailsVM.showError) { oldValue, newValue in
                
            }
            .onChange(of: paymentDetailsVM.paymentDeleted) { oldValue, newValue in
                shouldRefreshListEvent.send()
            }
            .onReceive(shouldRefreshDetailView, perform: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1,
                                              execute: {
                    self.paymentDetailsVM.getPaymentData()
                    self.shouldRefreshListEvent.send()
                    self.dismiss()
                })
            })
            
        }
    }
}

#Preview {
    PaymentDetailsView(
        paymentRegistryDTO: PaymentRegistryDTO(),
        shouldRefreshListEvent: .constant(PassthroughSubject<Void, Never>()),
        navPath: .constant([""])
    )
}
