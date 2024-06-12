//
//  SmartSavingsMainView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 29/03/24.
//

import SwiftUI
import PersistenceModule
import Combine

struct SmartSavingsMainView: View {
    @State private var presentingSheet = false
    @State private var presentingPaymentDetailSheet = false
    @State var dataSavedEvent = PassthroughSubject<Void, Never>()
    @State var paymentRegistryDTO = PaymentRegistryDTO()
    @State var shouldRefreshListEvent = PassthroughSubject<Void, Never>()
    
    @State var month: Int = 0
    @State var year: Int = 0
    
    @State var totalBalance: Double = 0
    @State var totalIncome: Double = 0
    @State var totalExpence: Double = 0
        
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                ScrollView(showsIndicators: false) {
                    CalendarSectionView(
                        month: $month,
                        year: $year
                    )
                    BalanceView(
                        totalBalance: $totalBalance,
                        totalIncome: $totalIncome,
                        totalExpence: $totalExpence
                    )
                    PaymentsTransactionsListView(
                        presentPaymentDetail: $presentingPaymentDetailSheet,
                        dataSavedEvent: $dataSavedEvent,
                        month: $month,
                        year: $year,
                        totalBalance: $totalBalance,
                        totalIncome: $totalIncome,
                        totalExpence: $totalExpence, 
                        paymentRegistryDTO: $paymentRegistryDTO, 
                        shouldRefreshListEvent: $shouldRefreshListEvent
                    )
                    .sheet(isPresented: $presentingPaymentDetailSheet, 
                           content: {
                        PaymentDetailsView(
                            paymentRegistryDTO: $paymentRegistryDTO,
                            shouldRefreshListEvent: $shouldRefreshListEvent,
                            presentPaymentDetail: $presentingPaymentDetailSheet
                        )
                        .padding()
                        .presentationDetents([.fraction(0.75), .height(400)])
                    })
                }
            }
            .navigationTitle("Personal Finance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "gear")
                            .padding(.horizontal)
                            .foregroundColor(Color.black)
                            .font(.title2)
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        presentingSheet = true
                    }) {
                        Image(systemName: "plus.circle")
                            .padding(.horizontal)
                            .foregroundColor(Color.black)
                            .font(.title2)
                            .bold()
                    }
                    .sheet(isPresented: $presentingSheet, 
                           content: {
                        AddPaymentView(dataSaved: $dataSavedEvent)
                    })
                }
            }
        }
    }
}

#Preview {
    SmartSavingsMainView()
}
