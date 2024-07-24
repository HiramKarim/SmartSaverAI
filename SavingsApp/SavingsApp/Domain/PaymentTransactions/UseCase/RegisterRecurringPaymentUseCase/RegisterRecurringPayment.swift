//
//  RegisterRecurringPayment.swift
//  SavingsApp
//
//  Created by Hiram Castro on 23/07/24.
//

import Foundation
import PersistenceModule
import Combine

protocol RegisterRecurringPaymentUCProtocol {
    func savePayment(payment: PaymentRegistryDTO, 
                     frecuency: String,
                     endDate: Date) -> Future<Void, Error>
}

class RegisterRecurringPaymentUseCase: PaymentTransactionBase {
    override init(coreDataManager: any CoreDataProtocol = CoreDataManager.shared) {
        super.init(coreDataManager: coreDataManager)
    }
}

extension RegisterRecurringPaymentUseCase: RegisterRecurringPaymentUCProtocol {
    func savePayment(payment: PaymentRegistryDTO,
                     frecuency: String,
                     endDate: Date) -> Future<Void, any Error> {
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
                self.coreDataManager.saveRecurringPayment(payment: paymentDTO,
                                                          frecuency: frecuency,
                                                          endDate: endDate) { result in
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
