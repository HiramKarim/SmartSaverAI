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
    @Binding var paymentRegistryDTO: PaymentRegistryDTO
    @Binding var shouldRefreshListEvent: PassthroughSubject<Void, Never>
    
    @State private var allButton:Bool = true
    @State private var incomeButton:Bool = false
    @State private var expenceButton:Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Recent transactions")
                .font(.getCustomFont(ofFont: .HelveticaBlkIt, ofSize: 20))
            
            LazyVStack(spacing: 10) {
                ForEach($vm.dataPaymentArray, id: \.self) { payment in
                    HStack(spacing: 10) {
                        Image(systemName: payment.typeNum.wrappedValue == 2 ? "arrowtriangle.down.circle" : "arrowtriangle.up.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(payment.typeNum.wrappedValue == 2 ? Color.red : Color.green)
                        VStack(alignment: .leading, spacing: 10) {
                            Text(payment.name.wrappedValue)
                                .lineLimit(2)
                                .font(.callout)
                            Text(payment.date.wrappedValue.convertToString(withFormat: .fullDate))
                                .font(.callout)
                                .foregroundStyle(Color.gray)
                        }
                        .padding()
                        Spacer()
                        Text("\(payment.amount.wrappedValue, specifier: "%.2f")")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color.white)
                    )
                    .onTapGesture {
                        paymentRegistryDTO = payment.wrappedValue
                        presentPaymentDetail = true
                    }
                }
            }
        }
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
        .padding()
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
        paymentRegistryDTO: .constant(PaymentRegistryDTO()), 
        shouldRefreshListEvent: .constant(PassthroughSubject<Void, Never>())
    )
}
