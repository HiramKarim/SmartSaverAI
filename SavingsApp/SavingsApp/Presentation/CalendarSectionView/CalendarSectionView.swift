//
//  CalendarSectionView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 10/04/24.
//

import SwiftUI

struct CalendarSectionView: View {

    @ObservedObject var vm = CalendarSectionVM()
    
    enum AlterMonth: Int {
        case increase = 1
        case decrease = -1
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                vm.alterMonth(using: AlterMonth.decrease.rawValue)
            } label: {
                Image(systemName: "arrow.backward.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.white)
            }
            
            Spacer()
            
            Text(vm.dateText)
                .font(.headline)
                .foregroundStyle(Color.white)
                .overlay {
                    DatePicker("", 
                               selection: $vm.currentDate,
                               displayedComponents: .date)
                        .blendMode(.destinationOver)
                        .onChange(of: vm.currentDate) { oldValue, newValue in
                            
                        }
                }
            
            Spacer()
            
            Button {
                vm.alterMonth(using: AlterMonth.increase.rawValue)
            } label: {
                Image(systemName: "arrow.right.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.white)
            }
        }
        .frame(width: 320)
        .padding()
        .background(
                Capsule()
                    .foregroundStyle(Color.green)
        )
        .onAppear {
            vm.getCurrentDateFormatted()
        }
    }
}

#Preview {
    CalendarSectionView()
}