//
//  PaymentDetailsView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 06/04/24.
//

import SwiftUI
import Combine

struct PaymentDetailsView: View {
    
    @Binding var paymentRegistryDTO: PaymentRegistryDTO
    @Binding var shouldRefreshListEvent: PassthroughSubject<Void, Never>
    @Binding var presentPaymentDetail: Bool
    @Binding var presentingUpdatePaymentSheet: Bool
    @Binding var paymentViewStateEvent:PassthroughSubject<PaymentViewState, Never>
    
    @State private var showDeleteAlert = false
    @State private var showUpdate = false
    
    @ObservedObject var paymentDetailsVM = PaymentDetailsVM(deleteUseCase: DeletePaymentUseCase(),
                                                            fetchByNameUseCase: FetchPaymentByNameUseCase())
    
    @Binding var navPath: [String]
    
    @State var shouldRefreshDetailView = PassthroughSubject<Void, Never>()
    
    private func startTimeForUpdateSheet() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presentingUpdatePaymentSheet = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.paymentViewStateEvent.send(.update)
            }
        }
    }
    
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
                                    presentPaymentDetail = false
                                    navPath.removeAll()
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
                                paymentRegistryDTO: $paymentRegistryDTO,
                                paymentViewState: .update,
                                paymentViewStateEvent: $paymentViewStateEvent,
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
                presentPaymentDetail = false
            }
            .onChange(of: paymentDetailsVM.paymentDeleted) { oldValue, newValue in
                shouldRefreshListEvent.send()
                presentPaymentDetail = false
            }
            .onReceive(shouldRefreshDetailView, perform: { _ in
                self.shouldRefreshListEvent.send()
                self.paymentDetailsVM.getPaymentData()
            })
            
        }
    }
}

#Preview {
    PaymentDetailsView(
        paymentRegistryDTO: .constant(PaymentRegistryDTO()),
        shouldRefreshListEvent: .constant(PassthroughSubject<Void, Never>()),
        presentPaymentDetail: .constant(false),
        presentingUpdatePaymentSheet: .constant(false),
        paymentViewStateEvent: .constant(PassthroughSubject<PaymentViewState, Never>()), 
        navPath: .constant([""])
    )
}
