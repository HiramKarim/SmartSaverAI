//
//  SmartSavingsMainView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 29/03/24.
//

import SwiftUI
import PersistenceModule
import Combine

enum PaymentViewState {
    case insert
    case update
}

struct SmartSavingsMainView: View {
    @State private var presentingAddPaymentSheet = false
    @State private var presentingPaymentDetailSheet = false
    @State private var presentingUpdatePaymentSheet = false
    @State var dataSavedEvent = PassthroughSubject<Void, Never>()
    @State var paymentRegistryDTO = PaymentRegistryDTO()
    @State var shouldRefreshListEvent = PassthroughSubject<Void, Never>()
    
    @State var month: Int = 0
    @State var year: Int = 0
    
    @State var totalBalance: Double = 0
    @State var totalIncome: Double = 0
    @State var totalExpence: Double = 0
    
    private var paymentViewState: PaymentViewState = .insert
    @State var paymentViewStateEvent = PassthroughSubject<PaymentViewState, Never>()
        
    var body: some View {
        
        TabView {
            ZStack {
                NavigationStack {
                    ZStack {
                        LinearGradient(gradient: .init(colors: [
                            Color.init("GradientColor-1", bundle: nil),
                            Color.init("GradientColor-2", bundle: nil),
                            Color.init("GradientColor-3", bundle: nil)
                        ]), startPoint: .top,
                            endPoint: .bottom)
                        .ignoresSafeArea(.all)
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
                                        presentPaymentDetail: $presentingPaymentDetailSheet,
                                        presentingUpdatePaymentSheet: $presentingUpdatePaymentSheet,
                                        paymentViewStateEvent: $paymentViewStateEvent
                                    )
                                    .padding()
                                    .presentationDetents([.fraction(0.75), .height(400)])
                                })
                                .sheet(isPresented: $presentingUpdatePaymentSheet,
                                       content: {
                                    AddPaymentView(
                                        dataSaved: $dataSavedEvent,
                                        paymentRegistryDTO:$paymentRegistryDTO,
                                        paymentViewState: .update,
                                        paymentViewStateEvent: $paymentViewStateEvent
                                    )
                                })
                            }
                        }
                        .navigationTitle("Finance Master")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button(action: {
                                    presentingAddPaymentSheet = true
                                }) {
                                    Image(systemName: "plus.circle")
                                        .padding(.horizontal)
                                        .foregroundColor(Color.black)
                                        .font(.title2)
                                        .bold()
                                }
                                .sheet(isPresented: $presentingAddPaymentSheet,
                                       content: {
                                    AddPaymentView(
                                        dataSaved: $dataSavedEvent,
                                        paymentRegistryDTO:$paymentRegistryDTO,
                                        paymentViewState: .insert,
                                        paymentViewStateEvent: $paymentViewStateEvent
                                    )
                                })
                            }
                        } // toolbar
                    }
                } // navigation stack
            }
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("home", systemImage: "house") }
            
            ZStack {
                
            }
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Chart", systemImage: "chart.pie.fill") }
            
            
            ZStack {
                
            }
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Settings", systemImage: "gear") }
        } // tab
    }
}

#Preview {
    SmartSavingsMainView()
}
