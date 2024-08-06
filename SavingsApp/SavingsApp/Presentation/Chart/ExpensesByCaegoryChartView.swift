//
//  ExpensesByCaegoryChartView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 05/08/24.
//

import SwiftUI
import Charts

struct ExpensesByCaegoryChartView: View {
    
    @ObservedObject private var vm = FetchCategoryPaymentsVM(useCase: FetchPaymentByDate())
    @Binding var month: Int
    @Binding var year: Int
    
    var body: some View {
        VStack {
            Chart {
                ForEach(vm.categoryExpenses) { data in
                    SectorMark(angle: .value("Share", data.amount),
                               innerRadius: MarkDimension.ratio(0.5),
                               outerRadius: MarkDimension.inset(50))
                    .foregroundStyle(by: .value("Owner", data.category))
                }
            }
        }
        .padding()
        .chartLegend(position: .bottom, alignment: .center)
        .dynamicTypeSize(.accessibility2)
        .onAppear(perform: {
            vm.fetchPayments(forMonth: month, year: year, limit: nil)
        })
    }
}

#Preview {
    ExpensesByCaegoryChartView(month: .constant(7),
                               year: .constant(2024))
}
