//
//  FetchRecurringPaymentUseCase.swift
//  SavingsApp
//
//  Created by Hiram Castro on 24/07/24.
//

import Foundation
import PersistenceModule

protocol FetchRecurringPaymentUseCaseProtocol {
    func fetchRecurringPayments(forPayment payment: PaymentRegistryDTO?) -> [RecurringPaymentDTO]
}

class FetchRecurringPaymentUseCase: PaymentTransactionBase {
    override init(coreDataManager: any CoreDataProtocol = CoreDataManager.shared) {
        super.init()
    }
}

extension FetchRecurringPaymentUseCase: FetchRecurringPaymentUseCaseProtocol {
    func fetchRecurringPayments(forPayment payment: PaymentRegistryDTO?) -> [RecurringPaymentDTO] {
        
        let paymentDTO: PersistenceModule.PaymentActivityDTO = .init(id: payment?.id ?? UUID(),
                                                                     name: payment?.name ?? "",
                                                                     memo: payment?.memo ?? "",
                                                                     date: payment?.date ?? Date(),
                                                                     amount: payment?.amount ?? 0.0,
                                                                     address: payment?.address ?? "",
                                                                     typeNum: payment?.typeNum ?? 0,
                                                                     paymentType: payment?.paymentType ?? 0)
        
        return self.coreDataManager.fetchRecurringPayments(forPayment: paymentDTO).compactMap { recurringPayment in
                .init(recurringID: recurringPayment.recurringID,
                      frequency: recurringPayment.frequency,
                      endDate: recurringPayment.endDate,
                      paymentActivity: self.validatePaymentData(payment: recurringPayment.paymentActivity)
                )
        }
    }
    
    private func validatePaymentData(payment: PaymentActivityDTO?) -> PaymentRegistryDTO? {
        guard let paymentActivity = payment else { return nil }
        return .init(id: paymentActivity.id,
                     name: paymentActivity.name,
                     memo: paymentActivity.memo,
                     date: paymentActivity.date,
                     amount: paymentActivity.amount,
                     address: paymentActivity.address ?? "",
                     typeNum: paymentActivity.typeNum,
                     paymentType: paymentActivity.paymentType)
    }
}
