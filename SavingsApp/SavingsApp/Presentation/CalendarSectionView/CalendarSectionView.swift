//
//  CalendarSectionView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 10/04/24.
//

import SwiftUI

struct CalendarSectionView: View {

    @ObservedObject var vm = CalendarSectionVM()
    
    @Binding var month: Int
    @Binding var year: Int
    
    @State private var showDateCarousell = false
    @State private var monthSelected = ""
    @State private var yearSelected = ""
    
    enum AlterMonth: Int {
        case increase = 1
        case decrease = -1
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                Button {
                    vm.alterMonth(using: AlterMonth.decrease.rawValue)
                } label: {
                    Image(systemName: "arrow.backward.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.init("black-color", bundle: nil))
                }
                
                Spacer()
                
                Text(vm.dateText)
                    .font(.headline)
                    .foregroundStyle(Color.init("black-color", bundle: nil))
                    .onTapGesture {
                        showDateCarousell = true
                    }
                
                Spacer()
                
                Button {
                    vm.alterMonth(using: AlterMonth.increase.rawValue)
                } label: {
                    Image(systemName: "arrow.right.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.init("black-color", bundle: nil))
                }
            }
            .frame(width: 320)
            .padding()
            .background(
                    Capsule()
                        .foregroundStyle(Color.lightBrown)
            )
            .onAppear {
                vm.getCurrentDateFormatted()
            }
            .onChange(of: vm.dateText) {
                self.month = vm.month
                self.year = vm.year
            }
            
            if $showDateCarousell.wrappedValue {
                ZStack {
                    Color.black
                        .opacity(0.4)
                        .ignoresSafeArea()
                    
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    Button("Close") {
                                        showDateCarousell = false
                                    }
                                }
                                .padding()
                                
                                HStack {
                                    Picker("Name", selection: $monthSelected) {
                                        Text("January").tag("January")
                                        Text("February").tag("February")
                                        Text("March").tag("March")
                                        Text("April").tag("April")
                                        Text("May").tag("May")
                                    }
                                    .pickerStyle(.wheel)
                                    
                                    Picker("Name", selection: $yearSelected) {
                                        Text("2000").tag("2000")
                                        Text("2001").tag("2001")
                                        Text("2002").tag("2002")
                                        Text("2003").tag("2003")
                                        Text("2004").tag("2004")
                                    }
                                    .pickerStyle(.wheel)
                                }
                                
                                Button("Aceptar") {
                                    vm.convertDateSelectedOf(month: monthSelected, andYear: yearSelected)
                                    showDateCarousell = false
                                }
                                .frame(width: 100, height: 50)
                                .background(Color.blue, in: Capsule())
                                .foregroundStyle(Color.white)
                            }
                            .padding()
                        )
                        .frame(width: 300, height: 250)
                }
            }
            
        }
    }
}

#Preview {
    CalendarSectionView(month: .constant(1), year: .constant(1))
}
