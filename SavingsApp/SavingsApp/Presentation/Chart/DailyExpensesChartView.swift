//
//  DailyExpensesChartView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 22/07/24.
//

import SwiftUI
import Charts

struct Expense: Identifiable {
    var id = UUID()
    var day: String
    var amount: Double
}

struct DailyExpensesChartView: View {
    
    let expenses: [Expense] = [
            Expense(day: "Lunes", amount: 45),
            Expense(day: "Martes", amount: 30),
            Expense(day: "Miércoles", amount: 60),
            Expense(day: "Jueves", amount: 25),
            Expense(day: "Viernes", amount: 75),
            Expense(day: "Sábado", amount: 90),
            Expense(day: "Domingo", amount: 50)
        ]
    
    var body: some View {
        VStack {
            Text("Gastos Semanales")
                .font(.title)
                .padding()
            
            Chart {
                ForEach(expenses) { expense in
                    BarMark(
                        x: .value("Día", expense.day),
                        y: .value("Cantidad", expense.amount)
                    )
                    .foregroundStyle(by: .value("Día", expense.day))
                }
            }
            .chartLegend(.hidden)
            .padding()
        }
    }
}

#Preview {
    DailyExpensesChartView()
}
