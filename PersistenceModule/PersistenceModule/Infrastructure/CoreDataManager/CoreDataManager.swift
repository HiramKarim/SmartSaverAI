//
//  CoreDataManager.swift
//  PersistenceModule
//
//  Created by Hiram Castro on 28/03/24.
//

import CoreData
import Combine

public class CoreDataManager: ObservableObject {
    
    let persistentContainer: NSPersistentContainer
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
    
    public func savePayment() {
        do {
            try persistentContainer.viewContext.save()
            getAllPayments() // update payments after saving
        } catch {
            print("Failed to save a movie")
        }
    }
    
    private func getAllPayments() {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        
        do {
            payments = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch payments \(error)")
        }
    }
    
    public func deletePayment(_ payment: PaymentActivity) {
        persistentContainer.viewContext.delete(payment) //not delete, just mark for deletion
        do {
            try persistentContainer.viewContext.save()
            getAllPayments() // update payments after saving
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to delete movie \(error)")
        }
    }
    
    public func getPaymentById(id: NSManagedObjectID) -> PaymentActivity? {
        do {
            return try persistentContainer.viewContext.existingObject(with: id) as? PaymentActivity
        } catch {
            print(error)
            return nil
        }
    }
    
}
