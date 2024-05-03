//
//  RegisterPaymentUseCase.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule

protocol RegisterPaymentUCProtocol {
    func savePayment(payment: PersistenceModule.PaymentActivityDTO, completion: @escaping (PaymentTransactionBase.PersistenceResult) -> Void)
}

class RegisterPaymentUseCase: PaymentTransactionBase {
    override init(coreDataManager: CoreDataProtocol = CoreDataManager.shared) {
        super.init(coreDataManager: coreDataManager)
    }
}

extension RegisterPaymentUseCase: RegisterPaymentUCProtocol {
    func savePayment(payment: PersistenceModule.PaymentActivityDTO, completion: @escaping (PaymentTransactionBase.PersistenceResult) -> Void) {
        concurrentQueue.async {
            self.coreDataManager.savePayment(payment: payment) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_): completion(.success(nil))
                    case .failure(let error): completion(.failure(error))
                    @unknown default:
                        fatalError("")
                    }
                }
            }
        }
    }
}
