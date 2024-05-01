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
    case success([PaymentActivity]?)
    case failure(Error?)
}

public protocol CoreDataProtocol {
    func savePayment(payment: PaymentActivityDTO,
                     completion: @escaping (PersistenceResult) -> Void)
    func fetchPayments(withName name: String?,
                       limit: Int?,
                       completion: @escaping (PersistenceResult) -> Void)
    func fetchPayments(forMonth month: Int,
                       year: Int,
                       limit: Int?,
                       completion: @escaping (PersistenceResult) -> Void)
    func deletePayment(_ object: NSManagedObject,
                       completion: @escaping (PersistenceResult) -> Void)
}

public class CoreDataManager {
    private let persistentContainer: NSPersistentContainer
    
    public static let shared = CoreDataManager()
    
    private var viewContext: NSManagedObjectContext {
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
    public func savePayment(payment: PaymentActivityDTO, completion: @escaping (PersistenceResult) -> Void) {
        let paymentInfo = PaymentActivity(context: viewContext)
        paymentInfo.paymentId = payment.id
        paymentInfo.name = payment.name
        paymentInfo.address = payment.address
        paymentInfo.amount = payment.amount
        paymentInfo.date = payment.date
        paymentInfo.memo = payment.memo
        paymentInfo.typeNum = payment.typeNum
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                completion(.success(nil))
            } catch {
                completion(.failure(ErrorPersistence.InsertionError))
            }
        }
    }
    
    public func deletePayment(_ object: NSManagedObject, completion: @escaping (PersistenceResult) -> Void) {
        viewContext.delete(object)
        do {
            try viewContext.save()
            completion(.success(nil))
        } catch {
            viewContext.rollback()
            let nserror = error as NSError
            completion(.failure(nserror))
        }
    }
    
    public func fetchPayments(withName name: String? = nil,
                              limit: Int? = nil,
                              completion: @escaping (PersistenceResult) -> Void) {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        if let name = name {
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        }
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        do {
            let result = try viewContext.fetch(fetchRequest)
            completion(.success(result))
        } catch {
            let nserror = error as NSError
            completion(.failure(nserror))
        }
    }
    
    public func fetchPayments(forMonth month: Int,
                              year: Int,
                              limit: Int? = nil,
                              completion: @escaping (PersistenceResult) -> Void) {
        let calendar = Calendar.current
        var startDateComponents = DateComponents()
        startDateComponents.year = year
        startDateComponents.month = month
        
        guard let startDate = calendar.date(from: startDateComponents) else {
            completion(.failure(NSError(domain: "Cannot calculate start date", code: 1)))
            return
        }
        
        guard let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else {
            completion(.failure(NSError(domain: "Cannot calculate end date", code: 1)))
            return
        }
        
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        fetchRequest.predicate = predicate
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            completion(.success(result))
        } catch {
            let nserror = error as NSError
            completion(.failure(nserror))
        }
    }
}
