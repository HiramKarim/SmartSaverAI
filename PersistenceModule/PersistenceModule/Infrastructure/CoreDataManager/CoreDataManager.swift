//
//  CoreDataManager.swift
//  PersistenceModule
//
//  Created by Hiram Castro on 28/03/24.
//

import CoreData

class CoreDataManager {
    
    let persistentContainer: NSPersistentContainer
    static let shared = CoreDataManager()
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "PaymentActivityModel")
        self.persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to initialize Core Data \(error)")
            }
        }
    }
    
    func savePayment() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save a movie")
        }
    }
    
    func getAllPayments() -> [PaymentActivity] {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func deletePayment(_ payment: PaymentActivity) {
        persistentContainer.viewContext.delete(payment) //not delete, just mark for deletion
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to delete movie \(error)")
        }
    }
    
    func getPaymentById(id: NSManagedObjectID) -> PaymentActivity? {
        do {
            return try persistentContainer.viewContext.existingObject(with: id) as? PaymentActivity
        } catch {
            print(error)
            return nil
        }
    }
    
}
