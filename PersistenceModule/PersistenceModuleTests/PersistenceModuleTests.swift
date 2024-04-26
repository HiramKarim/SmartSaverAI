//
//  PersistenceModuleTests.swift
//  PersistenceModuleTests
//
//  Created by Hiram Castro on 28/03/24.
//

import XCTest
import CoreData
@testable import PersistenceModule

final class PersistenceModuleTests: XCTestCase {
    
    let managerMock = CoreDataManagerMock()
    
    func testInsertPayment() throws {
        let paymentDTO = PaymentActivityDTO(id: UUID(),
                                            name: "Rent bill",
                                            memo: "just for test",
                                            date: Date(),
                                            amount: Double(20000),
                                            address: "Condesa",
                                            typeNum: Int32(1))
        
        var receivedError: Error?
        var data:[PaymentActivityDTO]?
        let exp = expectation(description: "wait for completion")
        
        managerMock.savePayment(payment: paymentDTO) { result in
            switch result {
            case .success(let payment):
                data = payment
            case .failure(let error):
                receivedError = error
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(data)
        XCTAssertNil(receivedError)
    }
    
    func testFetchAllPayments() {
        var receivedError: Error?
        var data:[PaymentActivityDTO]?
        let exp = expectation(description: "wait for completion")
        
        managerMock.getAllPayments(limit: 0) { result in
            switch result {
            case .success(let payment):
                data = payment
            case .failure(let error):
                receivedError = error
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(data)
        XCTAssertNil(receivedError)
    }

}

class CoreDataManagerMock {
    lazy var persistentContainer: NSPersistentContainer = {
        
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "PaymentActivityModel", withExtension:"momd")
        else { fatalError("Error loading model from bundle") }

        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: "PaymentActivityModel", managedObjectModel: mom)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}

extension CoreDataManagerMock: CoreDataProtocol {
    func savePayment(payment: PaymentActivityDTO, completion: @escaping (PersistenceResult) -> Void) {
        let paymentInfo = PaymentActivity(context: CoreDataManagerMock().persistentContainer.viewContext)
        paymentInfo.name = payment.name
        paymentInfo.address = payment.address
        paymentInfo.amount = payment.amount
        paymentInfo.date = payment.date
        paymentInfo.memo = payment.memo
        paymentInfo.typeNum = payment.typeNum
        do {
            try CoreDataManagerMock().persistentContainer.viewContext.save()
            completion(.success(nil))
        } catch {
            completion(.failure(NSError(domain: "Cannot insert", code: 0)))
        }
    }
    
    func getAllPayments(limit: Int, completion: @escaping (PersistenceResult) -> Void) {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        do {
            let payments = try CoreDataManagerMock().persistentContainer.viewContext.fetch(fetchRequest).compactMap { paymentActivity in
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
            completion(.failure(NSError(domain: "Cannot fetch", code: 0)))
        }
    }
    
    func deletePayment(payment: PaymentActivityDTO, completion: @escaping (PersistenceResult) -> Void) {
        let paymentInfo = PaymentActivity(context: CoreDataManagerMock().persistentContainer.viewContext)
        paymentInfo.name = payment.name
        CoreDataManagerMock().persistentContainer.viewContext.delete(paymentInfo) //not delete, just mark for deletion
        do {
            try CoreDataManagerMock().persistentContainer.viewContext.save()
            completion(.success(nil))
        } catch {
            CoreDataManagerMock().persistentContainer.viewContext.rollback()
            completion(.failure(NSError(domain: "Cannot Delete", code: 0)))
        }
    }
    
    
}
