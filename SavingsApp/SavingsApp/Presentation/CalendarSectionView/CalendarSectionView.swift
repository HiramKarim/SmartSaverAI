//
//  CalendarSectionView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 10/04/24.
//

import SwiftUI

struct CalendarSectionView: View {
    
    @State private var currentDate = Date()
    @State private var showCalendar = false
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                
            } label: {
                Image(systemName: "arrow.backward.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.white)
            }
            
            Spacer()
            
            Text("Marzo, 2024")
                .font(.headline)
                .foregroundStyle(Color.white)
                .onTapGesture {
                    showCalendar.toggle()
                    
                    if showCalendar {
                        print("show calendar")
                    }
                }
            
            Spacer()
            
            Button {
                
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
    }
}

#Preview {
    CalendarSectionView()
}
