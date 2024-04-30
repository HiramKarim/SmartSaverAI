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
    case FetchError
    case DeletionError
    case InitCoreDataError
}

public enum PersistenceResult {
    case success([PaymentActivityDTO]?)
    case failure(Error)
}

protocol CoreDataProtocol {
    func savePayment(payment: PaymentActivityDTO, completion: @escaping (PersistenceResult) -> Void)
    func getAllPayments(limit: Int?, completion: @escaping (PersistenceResult) -> Void)
    func deletePayment(payment: PaymentActivityDTO, completion: @escaping (PersistenceResult) -> Void)
}

public class CoreDataManager {
    private let persistentContainer: NSPersistentContainer
    
    public static let shared = CoreDataManager()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "PaymentActivityModel", withExtension:"momd")
        else { fatalError("Error loading model from bundle") }

        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        persistentContainer = NSPersistentContainer(name: "PaymentActivityModel", managedObjectModel: mom)
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Error al cargar el modelo persistente: \(error), \(error.userInfo)")
            }
        })
    }
}

extension CoreDataManager: CoreDataProtocol {
    
    ///Insert method
    public func savePayment(
        payment: PaymentActivityDTO,
        completion: @escaping (PersistenceResult) -> Void
    ) {
        let paymentInfo = PaymentActivity(context: persistentContainer.viewContext)
        paymentInfo.paymentId = payment.id
        paymentInfo.name = payment.name
        paymentInfo.address = payment.address
        paymentInfo.amount = payment.amount
        paymentInfo.date = payment.date
        paymentInfo.memo = payment.memo
        paymentInfo.typeNum = payment.typeNum
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                completion(.success(nil))
            } catch {
                completion(.failure(ErrorPersistence.InsertionError))
            }
        }
    }
    
    public func getAllPayments(
        limit: Int? = nil,
        completion: @escaping (PersistenceResult) -> Void
    ) {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        do {
            let payments = try persistentContainer.viewContext.fetch(fetchRequest).compactMap { paymentActivity in
                PaymentActivityDTO(id: paymentActivity.paymentId ?? UUID(),
                                   name: paymentActivity.name ?? "",
                                   memo: paymentActivity.memo,
                                   date: paymentActivity.date ?? Date(),
                                   amount: paymentActivity.amount,
                                   address: paymentActivity.address, 
                                   typeNum: paymentActivity.typeNum)
            }
            completion(.success(payments))
        } catch {
            completion(.failure(ErrorPersistence.FetchError))
        }
    }
    
    public func deletePayment(
        payment: PaymentActivityDTO,
        completion: @escaping (PersistenceResult) -> Void
    ) {
        let paymentInfo = PaymentActivity(context: persistentContainer.viewContext)
        paymentInfo.name = payment.name
        persistentContainer.viewContext.delete(paymentInfo)
        do {
            try persistentContainer.viewContext.save()
            completion(.success(nil))
        } catch {
            persistentContainer.viewContext.rollback()
            completion(.failure(ErrorPersistence.DeletionError))
        }
    }
}
