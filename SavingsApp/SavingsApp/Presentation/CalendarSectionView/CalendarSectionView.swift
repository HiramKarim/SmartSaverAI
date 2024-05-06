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
                    .foregroundStyle(Color.init("black-color", bundle: nil))
            }
            
            Spacer()
            
            Text(vm.dateText)
                .font(.headline)
                .foregroundStyle(Color.init("black-color", bundle: nil))
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
                    .foregroundStyle(Color.init("black-color", bundle: nil))
            }
        }
        .frame(width: 250)
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
    }
}

#Preview {
    CalendarSectionView(month: .constant(1), year: .constant(1))
}
