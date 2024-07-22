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

public enum RecurringResult {
    case success([RecurringPayment]?)
    case failure(Error?)
}

public protocol CoreDataProtocol {
    func savePayment(payment: PaymentActivityDTO,
                     completion: @escaping (PersistenceResult) -> Void)
    func saveRecurringPayment(payment: PaymentActivityDTO,
                              frecuency: String,
                              endDate: Date,
                              completion: @escaping (PersistenceResult) -> Void)
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

extension CoreDataManager {
    private func convertToDTO(payments:[PaymentActivity]) -> [PaymentActivityDTO] {
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
    
    private func convertRecurringPaymentsToDTO(recurringPayments: [RecurringPayment]) -> [RecurringPaymentDTO] {
        return recurringPayments.compactMap { recurringPayment in
            RecurringPaymentDTO(recurringID: recurringPayment.recurringID ?? UUID(),
                                frequency: recurringPayment.frequency ?? "",
                                endDate: recurringPayment.endDate ?? Date(),
                                paymentActivity: .init(id: recurringPayment.paymentActivity?.paymentId ?? UUID(),
                                                       name: recurringPayment.paymentActivity?.name ?? "",
                                                       memo: recurringPayment.paymentActivity?.memo ?? "",
                                                       date: recurringPayment.paymentActivity?.date ?? Date(),
                                                       amount: recurringPayment.paymentActivity?.amount ?? 0.0,
                                                       address: recurringPayment.paymentActivity?.address ?? "",
                                                       typeNum: recurringPayment.paymentActivity?.typeNum ?? 0,
                                                       paymentType: recurringPayment.paymentActivity?.paymentType ?? 0)
            )
        }
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
        paymentInfo.paymentType = payment.paymentType
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                completion(.success(nil))
            } catch {
                completion(.failure(ErrorPersistence.InsertionError))
            }
        }
    }
    
    public func updatePayment(payment: PaymentActivityDTO,
                              completion: @escaping (PersistenceResult) -> Void) {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "paymentId == %@", payment.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            
            if let paymentToUpdate = results.first {
                paymentToUpdate.name = payment.name
                paymentToUpdate.address = payment.address
                paymentToUpdate.amount = payment.amount
                paymentToUpdate.date = payment.date
                paymentToUpdate.memo = payment.memo
                paymentToUpdate.typeNum = payment.typeNum
                paymentToUpdate.paymentType = payment.paymentType
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                        completion(.success(nil))
                    } catch {
                        completion(.failure(ErrorPersistence.InsertionError))
                    }
                }
            }
        } catch {
            completion(.failure(ErrorPersistence.InsertionError))
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
    
    func fetchPaymentActivity(byId id: UUID) -> PaymentActivity? {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "paymentId == %@", id as CVarArg)
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result.first
        } catch {
            print("Error fetching PaymentActivity: \(error.localizedDescription)")
            return nil
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
    
    public func saveRecurringPayment(payment: PaymentActivityDTO, frecuency: String, endDate: Date, completion: @escaping (PersistenceResult) -> Void) {
        let context = viewContext
        let recurringPayment = RecurringPayment(context: context)
        var currentDate = payment.date
        
        recurringPayment.recurringID = UUID()
        recurringPayment.frequency = frecuency
        recurringPayment.endDate = endDate
        
        let paymentActivity = fetchPaymentActivity(byId: payment.id)
        
        recurringPayment.paymentActivity = paymentActivity
        
        switch frecuency {
        case "daily":
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        case "weekly":
            currentDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        case "monthly":
            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
        default:
            break
        }
        
        if context.hasChanges {
            do {
                try context.save()
                completion(.success(nil))
            } catch {
                completion(.failure(nil))
            }
        }
    }
    
    public func fetchRecurringPayments(forPayment payment: PaymentActivityDTO?) -> [RecurringPaymentDTO] {
        let fetchRequest: NSFetchRequest<RecurringPayment> = RecurringPayment.fetchRequest()
        if let payment = payment {
            fetchPayments(withName: payment.name) { result in
                switch result {
                case .success(let paymentActivityArray): 
                    if let paymentActivity = paymentActivityArray?.first {
                        fetchRequest.predicate = NSPredicate(format: "paymentActivity == %@", paymentActivity)
                    } else {
                        return
                    }
                case .failure():
                    break
                }
            }
        }
        do {
            let result = try viewContext.fetch(fetchRequest)
            return convertRecurringPaymentsToDTO(recurringPayments: result)
        } catch {
            print("Error al recuperar pagos: \(error.localizedDescription)")
            return []
        }
    }
    
    public func deleteRecurringPayment(forPayment payment: PaymentActivityDTO?, 
                                       completion: @escaping (PersistenceResult) -> Void) {
        let recurringPayments = fetchRecurringPayments(forPayment: payment)
        if recurringPayments.isEmpty {
            completion(false, nil)
        } else {
            guard let recurringPayment = recurringPayments.first else {
                completion(false, nil)
                return
            }
            deletePayment(recurringPayment, completion: completion)
        }
    }
}
