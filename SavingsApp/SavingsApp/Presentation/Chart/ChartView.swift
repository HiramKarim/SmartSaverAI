//
//  ChartView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 30/06/24.
//

import SwiftUI
import Charts

struct mockData: Identifiable {
    let id = UUID()
    let category:String
    let amount:Double
}

struct ChartView: View {
    
    let mockPayments = [
        mockData(category: "Bank", amount: 200),
        mockData(category: "Bank", amount: 600),
        mockData(category: "Rent", amount: 20000),
        mockData(category: "Groceries", amount: 2500)
    ]
    
    var body: some View {
        VStack {
            Chart(mockPayments) { data in
                SectorMark(angle: .value("Share", data.amount),
                           innerRadius: MarkDimension.ratio(0.5),
                           outerRadius: MarkDimension.inset(50))
                .foregroundStyle(by: .value("Owner", data.category))
            }
        }
        .chartLegend(position: .bottom, alignment: .center)
        .dynamicTypeSize(.accessibility2)
        .padding()
    }
}

#Preview {
    ChartView()
}
