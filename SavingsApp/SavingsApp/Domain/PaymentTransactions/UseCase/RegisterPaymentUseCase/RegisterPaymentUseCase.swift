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
    func savePayment(payment: PaymentRegistryDTO) -> Future<Void, Error>
}

class RegisterPaymentUseCase: PaymentTransactionBase {
    override init(coreDataManager: CoreDataProtocol = CoreDataManager.shared) {
        super.init(coreDataManager: coreDataManager)
    }
}

extension RegisterPaymentUseCase: RegisterPaymentUCProtocol {
    func savePayment(payment: PaymentRegistryDTO) -> Future<Void, Error> {
        
        let paymentDTO: PersistenceModule.PaymentActivityDTO = .init(id: payment.id,
                                                                     name: payment.name,
                                                                     memo: payment.memo,
                                                                     date: payment.date,
                                                                     amount: payment.amount,
                                                                     address: payment.address,
                                                                     typeNum: payment.typeNum,
                                                                     paymentType: payment.paymentType)
        
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            self.concurrentQueue.async {
                self.coreDataManager.savePayment(payment: paymentDTO) { result in
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
