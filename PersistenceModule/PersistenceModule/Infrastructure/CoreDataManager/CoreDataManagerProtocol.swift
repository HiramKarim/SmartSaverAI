//
//  CoreDataManagerProtocol.swift
//  PersistenceModule
//
//  Created by Hiram Castro on 23/07/24.
//

import CoreData
import Combine

public enum ErrorPersistence: Error {
    case InsertionError
    case FetchError
    case DeletionError
    case InitCoreDataError
}

public enum PersistenceResult {
    case success([PaymentActivityDTO]?)
    case failure(Error?)
}

public enum RecurringResult {
    case success([RecurringPaymentDTO]?)
    case failure(Error?)
}

public protocol CoreDataProtocol {
    func savePayment(payment: PaymentActivityDTO,
                     completion: @escaping (PersistenceResult) -> Void)
    func saveRecurringPayment(payment: PaymentActivityDTO,
                              frecuency: String,
                              endDate: Date,
                              completion: @escaping (RecurringResult) -> Void)
    func updatePayment(payment: PaymentActivityDTO,
                     completion: @escaping (PersistenceResult) -> Void)
    func fetchPayments(withName name: String?,
                       limit: Int?,
                       completion: @escaping (PersistenceResult) -> Void)
    func fetchPayments(forMonth month: Int,
                       year: Int,
                       limit: Int?,
                       completion: @escaping (PersistenceResult) -> Void)
    func fetchRecurringPayments(forPayment payment: PaymentActivityDTO?) -> [RecurringPaymentDTO]
    func deletePayment(_ object: NSManagedObject,
                       completion: @escaping (PersistenceResult) -> Void)
    func deleteRecurringPayment(forPayment payment: PaymentActivityDTO?,
                                completion: @escaping (RecurringResult) -> Void)
}
