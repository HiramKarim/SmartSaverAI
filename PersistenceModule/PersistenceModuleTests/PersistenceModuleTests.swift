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
        //given
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
        
        //when
        managerMock.savePayment(payment: paymentDTO) { result in
            switch result {
            case .success(let payment):
                data = payment
            case .failure(let error):
                receivedError = error
            }
            exp.fulfill()
        }
        
        //then
        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(data)
        XCTAssertNil(receivedError)
    }
    
    func testFetchAllPayments() {
        //given
        var receivedError: Error?
        var data:[PaymentActivityDTO]?
        let exp = expectation(description: "wait for completion")
        
        //when
        managerMock.getAllPayments(limit: 0) { result in
            switch result {
            case .success(let payment):
                data = payment
            case .failure(let error):
                receivedError = error
            }
            exp.fulfill()
        }
        
        //then
        wait(for: [exp], timeout: 1.0)
        XCTAssertGreaterThan(data?.count ?? 0, 0)
        XCTAssertNil(receivedError)
    }
    
    func testDeletePayment() {
        //given
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
        //when
        managerMock.deletePayment(payment: paymentDTO) { result in
            switch result {
            case .success(let payment):
                data = payment
            case .failure(let error):
                receivedError = error
            }
            exp.fulfill()
        }
        //then
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
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PaymentActivity")
        let predicate = NSPredicate(format: "name = %@", argumentArray: [payment.name]) // Specify your condition here
        fetch.predicate = predicate
        do {
            guard let paymentInfo = try CoreDataManagerMock().persistentContainer.viewContext.fetch(fetch).first as? PaymentActivity
            else {
                completion(.failure(NSError(domain: "Cannot fetch entity to delete", code: 0)))
                return
            }
            CoreDataManagerMock().persistentContainer.viewContext.delete(paymentInfo) //not delete, just mark for deletion
            try CoreDataManagerMock().persistentContainer.viewContext.save()
            completion(.success(nil))
        } catch {
            CoreDataManagerMock().persistentContainer.viewContext.rollback()
            completion(.failure(NSError(domain: "Cannot Delete", code: 0)))
        }
    }
}

class MockPersistentStoreContainer: NSPersistentContainer {
    init() {
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "PaymentActivityModel", withExtension:"momd") else {
            fatalError("Error loading model URL from bundle")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing managed object model from: \(modelURL)")
        }

        super.init(name: "PaymentActivity", managedObjectModel: managedObjectModel)

        let inMemoryStoreDescription = NSPersistentStoreDescription()
        inMemoryStoreDescription.type = NSInMemoryStoreType

        // En lugar de /dev/null, usa una URL temporal única para el almacenamiento en disco
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PaymentActivity.sqlite")
        let fileStoreDescription = NSPersistentStoreDescription(url: fileURL)

        self.persistentStoreDescriptions = [inMemoryStoreDescription, fileStoreDescription]

        self.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error)")
            }
        })
    }
}



struct PaymentCoreDataInteractor {
    var context : NSManagedObjectContext

    init(withContext context : NSManagedObjectContext) {
        self.context = context
    }

    func saveData(payment: PaymentActivityDTO) {
        self.context.performAndWait {
            do {
                let paymentInfo = PaymentActivity(context: self.context)
                paymentInfo.name = payment.name
                paymentInfo.address = payment.address
                paymentInfo.amount = payment.amount
                paymentInfo.date = payment.date
                paymentInfo.memo = payment.memo
                paymentInfo.typeNum = payment.typeNum
                try self.context.save()
            } catch {
                NSLog("Error while inserting data")
            }
        }
    }
}

class EmployeeCoreDataInteractorTests: XCTestCase {
    var paymentCoreDataInteractor: PaymentCoreDataInteractor?
    var context: NSManagedObjectContext?
    
    override func setUpWithError() throws {
        let persistentStore = MockPersistentStoreContainer.init()
        self.context = persistentStore.newBackgroundContext()
        self.paymentCoreDataInteractor = PaymentCoreDataInteractor.init(withContext: self.context!)
    }
    
    override func tearDownWithError() throws {
        self.context = nil
    }
    
    func testSaveData() {
        let paymentBillDTO = PaymentActivityDTO(id: UUID(),
                                            name: "Rent bill",
                                            memo: "just for test",
                                            date: Date(),
                                            amount: Double(20000),
                                            address: "Condesa",
                                            typeNum: Int32(1))
        let paymentGassDTO = PaymentActivityDTO(id: UUID(),
                                            name: "Gas",
                                            memo: "just for test",
                                            date: Date(),
                                            amount: Double(200),
                                            address: "Condesa",
                                            typeNum: Int32(1))
        self.paymentCoreDataInteractor?.saveData(payment: paymentBillDTO)
        self.paymentCoreDataInteractor?.saveData(payment: paymentGassDTO)
        do {
            try self.context?.performAndWait {
                let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
                let payments = try self.context?.fetch(fetchRequest)
                let first = payments?.first
                print(">>> \(first?.name ?? "")")
            }
        } catch {
            NSLog("Error while fetching data")
        }
    }
}
