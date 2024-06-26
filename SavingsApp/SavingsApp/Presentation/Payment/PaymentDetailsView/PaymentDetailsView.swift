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
    
    @ObservedObject var paymentDetailsVM = PaymentDetailsVM(deleteUseCase: DeletePaymentUseCase())
    
    
    private func startTimeForUpdateSheet() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presentingUpdatePaymentSheet = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.paymentViewStateEvent.send(.update)
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Text("Payment Details")
                    .font(.title)
                    .bold()
                Spacer()
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
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 20) {
                    Text(paymentDetailsVM.name)
                        .font(.title2)
                    
                    Spacer()
                    
                    Text(paymentDetailsVM.paymentType == 2 ? 
                         "-\(paymentDetailsVM.amount, specifier: "%.2f")" :
                            "\(paymentDetailsVM.amount, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(paymentDetailsVM.paymentType == 2 ? 
                                         Color.red :
                                            Color.green)
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
                    }, label: {
                        Text("Delete")
                            .bold()
                            .foregroundStyle(Color.white)
                    })
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.red, in: Capsule())
                    .controlSize(.large)
                    
                    Button(action: {
                        presentPaymentDetail = false
                        startTimeForUpdateSheet()
                    }, label: {
                        Text("Update")
                            .bold()
                            .foregroundStyle(Color.white)
                    })
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.blue, in: Capsule())
                    .controlSize(.large)
                }
            }
            
            Spacer()
        }
        .padding()
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
        .alert("Are you sure to delete?", isPresented: $showDeleteAlert) {
            Button(role: .destructive) {
                self.paymentDetailsVM.deletePayment()
            } label: {
                Text("Delete")
            }
        } message: {
            Text("This will permanently delete the registry.")
                .font(.largeTitle)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    PaymentDetailsView(
        paymentRegistryDTO: .constant(PaymentRegistryDTO()),
        shouldRefreshListEvent: .constant(PassthroughSubject<Void, Never>()),
        presentPaymentDetail: .constant(false),
        presentingUpdatePaymentSheet: .constant(false),
        paymentViewStateEvent: .constant(PassthroughSubject<PaymentViewState, Never>())
    )
}
