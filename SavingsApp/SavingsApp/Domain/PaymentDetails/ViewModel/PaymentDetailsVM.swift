//
//  PaymentDetailsVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 05/05/24.
//

import Foundation

class PaymentDetailsVM: ObservableObject {
    
    @Published var name: String = ""
    @Published var date: Date = Date()
    @Published var location: String = ""
    @Published var memo: String = ""
    @Published var amount: Double = 0.0
    @Published var paymentType: Int32 = 1
    
    func updateView(withPayment payment: PaymentRegistryDTO) {
        self.name = payment.name
        self.date = payment.date
        self.location = payment.address ?? ""
        self.memo = payment.memo ?? ""
        self.amount = payment.amount
        self.paymentType = payment.typeNum
    }
    
}
