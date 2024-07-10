//
//  TransactionsView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 29/03/24.
//

import SwiftUI
import Combine

struct PaymentsTransactionsListView: View {
    
    @ObservedObject private var vm = FetchPaymentByDateVM(
        fetchPaymentsByDateUseCase: FetchPaymentByDate()
    )
    
    @Binding var presentPaymentDetail: Bool
    @Binding var dataSavedEvent: PassthroughSubject<Void, Never>
    @Binding var month: Int
    @Binding var year: Int
    @Binding var totalBalance: Double
    @Binding var totalIncome: Double
    @Binding var totalExpence: Double
    @Binding var shouldRefreshListEvent: PassthroughSubject<Void, Never>
    
    @State private var allButton:Bool = true
    @State private var incomeButton:Bool = false
    @State private var expenceButton:Bool = false
    
    @Binding var navPath: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            if vm.dataPaymentArray.isEmpty {
                VStack {
                    Text("There's no transactions registered")
                        .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 15))
                        .foregroundStyle(Color.gray)
                }
                .padding()
            } else {
                Text("Recent transactions")
                    .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 20))
                    .foregroundStyle(Color.gray)
                
                    
                LazyVStack(spacing: 10) {
                    ForEach($vm.dataPaymentArray, id: \.self) { payment in
                        
                        NavigationLink {
                            PaymentDetailsView(
                                paymentRegistryDTO: payment.wrappedValue,
                                shouldRefreshListEvent: $shouldRefreshListEvent,
                                navPath: $navPath
                            )
                        } label: {
                            
                            HStack(spacing: 10) {
                                Image(systemName: payment.typeNum.wrappedValue == 2 ?
                                      "arrowtriangle.down.circle" :
                                        "arrowtriangle.up.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(payment.typeNum.wrappedValue == 2 ?
                                                     Color.red :
                                                     Color.green)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(payment.name.wrappedValue)
                                        .lineLimit(2)
                                        .minimumScaleFactor(1)
                                        .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 15))
                                        .foregroundStyle(Color.black)
                                    Text(payment.date.wrappedValue.convertToString(withFormat: .fullDate))
                                        .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 15))
                                        .foregroundStyle(Color.gray)
                                        .minimumScaleFactor(1)
                                }
                                
                                Spacer()
                                
                                Text("$\(payment.amount.wrappedValue, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundStyle(payment.typeNum.wrappedValue == 2 ?
                                                     Color.red :
                                                     Color.green)
                            } //cell
                            .frame(maxHeight: 80)
                            .padding()
                            
                        } //navigation
                    }
                }
                    
                
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
        .onReceive(dataSavedEvent, perform: { _ in
            vm.fetchPayments(forMonth: month, year: year, limit: nil)
        })
        .onChange(of: self.month, {
            vm.fetchPayments(forMonth: month, year: year, limit: nil)
        })
        .onReceive(shouldRefreshListEvent, perform: { _ in
            vm.fetchPayments(forMonth: month, year: year, limit: nil)
        })
        .onChange(of: self.vm.totalBalance, { oldValue, newValue in
            self.totalBalance = vm.totalBalance
            self.totalExpence = vm.totalExpence
            self.totalIncome = vm.totalIncome
        })
    }
}

#Preview {
    PaymentsTransactionsListView(
        presentPaymentDetail: .constant(true),
        dataSavedEvent: .constant(PassthroughSubject<Void, Never>()),
        month: .constant(5),
        year: .constant(2024),
        totalBalance: .constant(0.0),
        totalIncome: .constant(0.0),
        totalExpence: .constant(0.0),
        shouldRefreshListEvent: .constant(PassthroughSubject<Void, Never>()), 
        navPath: .constant([""])
    )
}
