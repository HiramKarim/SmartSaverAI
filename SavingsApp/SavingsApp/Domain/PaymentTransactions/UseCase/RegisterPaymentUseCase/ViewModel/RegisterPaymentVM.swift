//
//  PaymentManagerVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule

class RegisterPaymentVM: ObservableObject {
    
    private let registerPaymentUseCase: RegisterPaymentUCProtocol
    
    init(registerPaymentUseCase: RegisterPaymentUCProtocol) {
        self.registerPaymentUseCase = registerPaymentUseCase
    }
    
    internal func registerPayment() {
        self.registerPaymentUseCase.savePayment(payment: <#T##PaymentActivityDTO#>, completion: <#T##(PaymentTransactionBase.PersistenceResult) -> Void#>)
    }
    
}
