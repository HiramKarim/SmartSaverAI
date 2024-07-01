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
                        //showDateCarousell = true
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
                        .foregroundStyle(Color.init("pale-green", bundle: nil))
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
                                        ForEach(vm.getMonths(), id: \.self) { month in
                                            Text(month).tag(month)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    
                                    Picker("Name", selection: $yearSelected) {
                                        ForEach(vm.getRangeOfYear(), id: \.self) { year in
                                            Text(String(year)).tag(String(year))
                                        }
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
