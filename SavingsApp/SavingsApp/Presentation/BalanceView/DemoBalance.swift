//
//  DemoBalance.swift
//  SavingsApp
//
//  Created by Hiram Castro on 30/06/24.
//

import SwiftUI

import SwiftUI

struct MainBalanceView: View {
    var body: some View {
        VStack {
            // Barra de Navegación Superior
            HStack {
                Text("FinanceMaster")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(Color.gray)
                Spacer()
                HStack(spacing: 20) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(Color.gray)
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(Color.gray)
                }
            }
            .padding()
            .background(Color.white)
            
            // Resumen del Balance
            VStack(alignment: .leading, spacing: 10) {
                Text("Balance Actual")
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .foregroundColor(Color(hex: "#666666"))
                Text("$0")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundColor(Color(hex: "#00A1E4"))
                HStack {
                    VStack(alignment: .leading) {
                        Text("Ingresos")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(Color(hex: "#666666"))
                        Text("$0")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(Color(hex: "#70D44B"))
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Gastos")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(Color(hex: "#666666"))
                        Text("$0")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(Color(hex: "#00C7B1"))
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
            
            // Gráfica de Gastos
            VStack {
                Text("Distribución de Gastos")
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .foregroundColor(Color.gray)
                PieChartView()
                    .frame(height: 200)
                    .background(Color.red)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
            
            // Lista de Transacciones Recientes
            VStack(alignment: .leading) {
                Text("Transacciones Recientes")
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .foregroundColor(Color.black)
                List {
                    TransactionRowView(category: "Comida", 
                                       description: "Cena en restaurante",
                                       amount: "$50.00",
                                       date: "25 Jun")
                    TransactionRowView(category: "Transporte", 
                                       description: "Gasolina",
                                       amount: "$40.00",
                                       date: "24 Jun")
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            
            Spacer()
            
            // Botones de Acción
            HStack(spacing: 20) {
                Button(action: {
                    // Acción para añadir ingreso
                }) {
                    Text("Añadir Ingreso")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    // Acción para añadir gasto
                }) {
                    Text("Añadir Gasto")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            // Barra de Navegación Inferior
            HStack {
                Image(systemName: "house.fill")
                    .foregroundColor(Color(hex: "#00A1E4"))
                Spacer()
                Image(systemName: "list.bullet")
                    .foregroundColor(Color.gray)
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color.gray)
                Spacer()
                Image(systemName: "gearshape.fill")
                    .foregroundColor(Color.gray)
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 5)
        }
        .background(Color.white)
    }
}

struct TransactionRowView: View {
    var category: String
    var description: String
    var amount: String
    var date: String
    
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(description)
                    .font(.system(size: 16, weight: .regular, design: .default))
                Text(date)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(Color.green)
            }
            Spacer()
            Text(amount)
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(Color.green)
        }
        .padding(.vertical, 10)
    }
}

struct PieChartView: View {
    var body: some View {
        Text("Pie Chart Placeholder")
        // Aquí puedes usar un paquete de gráficos como Charts para mostrar la gráfica real
    }
}

struct MainBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        MainBalanceView()
    }
}

#Preview {
    MainBalanceView()
}
