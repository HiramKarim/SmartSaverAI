//
//  CoreDataManager.swift
//  PersistenceModule
//
//  Created by Hiram Castro on 28/03/24.
//

import CoreData
import Combine

private enum ErrorPersistence: Error {
    case InsertionError
    case ConsultError
    case DeletionError
    case InitCoreDataError
}

public enum PersistenceResult {
    case success([PaymentActivityDTO]?)
    case failure(Error)
}

protocol CoreDataProtocol {
    func savePayment(payment: PaymentActivityDTO, completion: @escaping (PersistenceResult) -> Void)
    func getAllPayments(limit:Int,completion: @escaping (PersistenceResult) -> Void)
    func deletePayment(payment: PaymentActivityDTO, completion: @escaping (PersistenceResult) -> Void)
}

public class CoreDataManager {
    private let persistentContainer: NSPersistentContainer
    public static let shared = CoreDataManager()
    
    private init() {

        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "PaymentActivityModel", withExtension:"momd")
        else { fatalError("Error loading model from bundle") }

        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        self.persistentContainer = NSPersistentContainer(name: "PaymentActivity",
                                                         managedObjectModel: mom)
        self.persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to initialize Core Data \(error)")
            }
        }
    }
}

extension CoreDataManager: CoreDataProtocol {
    
    ///Insert method
    public func savePayment(
        payment: PaymentActivityDTO,
        completion: @escaping (PersistenceResult) -> Void
    ) {
        let paymentInfo = PaymentActivity(context: persistentContainer.viewContext)
        paymentInfo.name = payment.name
        paymentInfo.address = payment.address
        paymentInfo.amount = payment.amount
        paymentInfo.date = payment.date
        paymentInfo.memo = payment.memo
        paymentInfo.typeNum = payment.typeNum
        do {
            try persistentContainer.viewContext.save()
            completion(.success(nil))
        } catch {
            completion(.failure(ErrorPersistence.InsertionError))
        }
    }
    
    public func getAllPayments(
        limit: Int,
        completion: @escaping (PersistenceResult) -> Void
    ) {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        do {
            let payments = try persistentContainer.viewContext.fetch(fetchRequest).compactMap { paymentActivity in
                PaymentActivityDTO(id: UUID(),
                                   name: paymentActivity.name ?? "",
                                   memo: paymentActivity.memo,
                                   date: paymentActivity.date ?? Date(),
                                   amount: paymentActivity.amount,
                                   address: paymentActivity.address, 
                                   typeNum: paymentActivity.typeNum)
            }
            completion(.success(payments))
        } catch {
            completion(.failure(ErrorPersistence.ConsultError))
        }
    }
    
    public func deletePayment(
        payment: PaymentActivityDTO,
        completion: @escaping (PersistenceResult) -> Void
    ) {
        let paymentInfo = PaymentActivity(context: persistentContainer.viewContext)
        paymentInfo.name = payment.name
        persistentContainer.viewContext.delete(paymentInfo) //not delete, just mark for deletion
        do {
            try persistentContainer.viewContext.save()
            completion(.success(nil))
        } catch {
            persistentContainer.viewContext.rollback()
            completion(.failure(ErrorPersistence.DeletionError))
        }
    }
}
