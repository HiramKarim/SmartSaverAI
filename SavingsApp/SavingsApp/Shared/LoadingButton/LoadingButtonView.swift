//
//  LoadingButtonView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 04/05/24.
//

import SwiftUI

struct LoadingButtonView: View {
    
    @Binding var isLoading: Bool
    @Binding var isSuccess: Bool
    
    var body: some View {
        Button(action: {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2,
                                          execute: {
                isLoading = false
                isSuccess = true
            })
        }, label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .foregroundStyle(Color.white)
            } else if isSuccess {
                Image(systemName: "checkmark")
                Text("Success")
                    .font(.headline)
                    .foregroundStyle(Color.white)
            } else {
                Text("Save")
                    .font(.headline)
                    .foregroundStyle(Color.white)
            }
        })
        .padding()
        .frame(maxWidth: .infinity)
        .background(isLoading || isSuccess ? Color.green : Color.purple, in: Capsule())
        .opacity(isSuccess ? 0.5 : 1.0)
        .disabled(isLoading)
        .controlSize(.large)

    }
}

#Preview {
    LoadingButtonView(isLoading: .constant(false), isSuccess: .constant(false))
}
