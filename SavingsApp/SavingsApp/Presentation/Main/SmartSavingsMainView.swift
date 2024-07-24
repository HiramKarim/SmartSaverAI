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
    
    @State private var navPath: [String] = []
        
    var body: some View {
        
        TabView {
            ZStack {
                NavigationStack(path: $navPath) {
                    ZStack {
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
                                    shouldRefreshListEvent: $shouldRefreshListEvent, 
                                    navPath: $navPath
                                )
                            }
                        }
                        .navigationTitle("Finance Master")
                        .navigationDestination(for: String.self, destination: { pathValue in
                            if pathValue == "AddPaymentView" {
                                AddPaymentView(
                                    dataSaved: $dataSavedEvent,
                                    paymentRegistryDTO: PaymentRegistryDTO(),
                                    paymentViewState: .insert,
                                    navPath: $navPath, 
                                    shouldRefreshDetailView: .constant(PassthroughSubject<Void, Never>())
                                )
                            }
                        })
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink(value: "AddPaymentView") {
                                    Image(systemName: "plus.circle")
                                        .padding(.horizontal)
                                        .foregroundColor(Color.black)
                                        .font(.title2)
                                        .bold()
                                }
                            }
                        } // toolbar
                    }
                } // navigation stack
            }
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("home", systemImage: "house") }
            
            ZStack {
                DailyExpensesChartView()
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
