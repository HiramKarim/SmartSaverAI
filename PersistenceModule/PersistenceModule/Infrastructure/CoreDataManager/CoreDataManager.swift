//
//  CoreDataManager.swift
//  PersistenceModule
//
//  Created by Hiram Castro on 28/03/24.
//

import CoreData
import Combine

protocol CoreDataProtocol {
    func savePayment(payment: PaymentActivityDTO)
    func getAllPayments(limit:Int)
    func deletePayment(payment: PaymentActivityDTO)
}

public class CoreDataManager: ObservableObject {
    private let persistentContainer: NSPersistentContainer
    public static let shared = CoreDataManager()
    
    @Published var payments: [PaymentActivity] = []
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "PaymentActivityModel")
        self.persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to initialize Core Data \(error)")
            }
        }
    }
}

extension CoreDataManager: CoreDataProtocol {
    public func savePayment(payment: PaymentActivityDTO) {
        let paymentInfo = PaymentActivity(context: persistentContainer.viewContext)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save a movie")
        }
    }
    
    public func getAllPayments(limit: Int) {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        do {
            payments = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch payments \(error)")
        }
    }
    
    public func deletePayment(payment: PaymentActivityDTO) {
        let paymentInfo = PaymentActivity(context: persistentContainer.viewContext)
        paymentInfo.name = payment.name
        persistentContainer.viewContext.delete(paymentInfo) //not delete, just mark for deletion
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to delete movie \(error)")
        }
    }
}
