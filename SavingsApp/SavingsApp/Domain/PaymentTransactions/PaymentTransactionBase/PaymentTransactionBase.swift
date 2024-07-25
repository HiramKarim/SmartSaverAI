//
//  PaymentTransactionBase.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule

class PaymentTransactionBase {

    internal enum ErrorPersistence: Error {
        case InsertionError
        case FetchError
        case DeletionError
        case InitCoreDataError
    }
    
    internal enum PersistenceResult {
        case success([PaymentActivityDTO]?)
        case failure(Error?)
    }
    
    internal enum RecurringPersistenceResult {
        case success([RecurringPaymentDTO]?)
        case failure(Error?)
    }
    
    internal let coreDataManager: CoreDataProtocol
    internal let concurrentQueue = DispatchQueue(label: "com.SmartSavings.coredata", attributes: .concurrent)

    init(coreDataManager: CoreDataProtocol = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }

    internal func convertToDTO(payments:[PaymentActivity]) -> [PaymentActivityDTO] {
        return payments.compactMap { paymentActivity in
            PaymentActivityDTO(id: paymentActivity.paymentId ?? UUID(),
                               name: paymentActivity.name ?? "",
                               memo: paymentActivity.memo ?? "",
                               date: paymentActivity.date ?? Date(),
                               amount: paymentActivity.amount,
                               address: paymentActivity.address ?? "",
                               typeNum: paymentActivity.typeNum,
                               paymentType: paymentActivity.paymentType)
        }
    }
}

