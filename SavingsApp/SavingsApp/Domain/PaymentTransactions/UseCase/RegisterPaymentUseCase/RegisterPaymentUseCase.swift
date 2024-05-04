//
//  RegisterPaymentUseCase.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule
import Combine

protocol RegisterPaymentUCProtocol {
    func savePayment(payment: PersistenceModule.PaymentActivityDTO, completion: @escaping (PaymentTransactionBase.PersistenceResult) -> Void)
    func savePayment(payment: PersistenceModule.PaymentActivityDTO) -> Future<Void, Error>
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

extension RegisterPaymentUseCase {
    func savePayment(payment: PersistenceModule.PaymentActivityDTO) -> Future<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            self.concurrentQueue.async {
                self.coreDataManager.savePayment(payment: payment) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_): 
                            promise(.success(()))
                        case .failure(let error): 
                            promise(.failure(error!))
                        @unknown default:
                            fatalError("")
                        }
                    }
                }
            }
        }
    }
}
