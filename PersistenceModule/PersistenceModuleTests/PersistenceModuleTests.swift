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

class MockCoreDataStack: CoreDataStack {
    override init() {
        super.init()

        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "PaymentActivityModel", withExtension:"momd")
        else { fatalError("Error loading model from bundle") }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) 
        else { fatalError("Error initializing mom from: \(modelURL)") }
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        let container = NSPersistentContainer(name: "PaymentActivityModel", managedObjectModel: mom)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        self.persistentContainer = container
    }
}

class CoreDataStack {
    static let shared = CoreDataStack()

    init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "PaymentActivityModel", withExtension:"momd")
        else { fatalError("Error loading model from bundle") }

        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let container = NSPersistentContainer(name: "PaymentActivityModel", managedObjectModel: mom)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Error al cargar el modelo persistente: \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext (payment: PaymentActivityDTO, completion: @escaping (Bool, NSError?) -> Void) {
        let context = persistentContainer.viewContext
        let paymentInfo = PaymentActivity(context: context)
        paymentInfo.paymentId = payment.id
        paymentInfo.name = payment.name
        paymentInfo.address = payment.address
        paymentInfo.amount = payment.amount
        paymentInfo.date = payment.date
        paymentInfo.memo = payment.memo
        paymentInfo.typeNum = payment.typeNum
        if context.hasChanges {
            do {
                try context.save()
                completion(true, nil)
            } catch {
                let nserror = error as NSError
                completion(false, nserror)
            }
        }
    }

    func deleteObject(_ object: NSManagedObject, completion: @escaping (Bool, NSError?) -> Void) {
        let context = persistentContainer.viewContext
        context.delete(object)
        do {
            try context.save()
            completion(true, nil)
        } catch {
            let nserror = error as NSError
            completion(false, nserror)
        }
    }

    func fetchObjects<T: NSManagedObject>(_ objectType: T.Type, limit: Int? = nil) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: objectType))
        if let limit = limit {
            request.fetchLimit = limit
        }
        do {
            let result = try viewContext.fetch(request)
            return result
        } catch {
            fatalError("Error al recuperar objetos: \(error)")
        }
    }
}

class PaymentManagerUseCase {
    let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }

    func saveData(payment: PaymentActivityDTO, completion: @escaping (Bool, NSError?) -> Void) {
        self.coreDataStack.saveContext(payment: payment) { success, error in
            completion(success, error)
        }
    }
    
    func fetchAllData() -> [PaymentActivity] {
        return self.coreDataStack.fetchObjects(PaymentActivity.self)
    }
}


class EmployeeCoreDataInteractorTests: XCTestCase {
    var context: NSManagedObjectContext?
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        self.context = nil
    }
    
    func testSaveData() {
        //given
        let mockCoreDataStack = MockCoreDataStack()
        let sut = PaymentManagerUseCase(coreDataStack: mockCoreDataStack)
        let paymentBillDTO = PaymentActivityDTO(id: UUID(),
                                            name: "Rent bill",
                                            memo: "just for test",
                                            date: Date(),
                                            amount: Double(20000),
                                            address: "Condesa",
                                            typeNum: Int32(1))
        let exp = expectation(description: "wait for completion")
        var result:Bool = false
        
        //when
        sut.saveData(payment: paymentBillDTO) { success, error in
            result = success
            exp.fulfill()
        }
        
        let paymentData = sut.fetchAllData()
        let firstElement = paymentData.first
        //then
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(result)
        XCTAssertNotNil(paymentData)
        XCTAssertGreaterThan(paymentData.count, 0)
        XCTAssertEqual(paymentData[0].name ?? "", "Rent bill")
    }
    
    func testFetchAllData() {
        //given
        let mockCoreDataStack = MockCoreDataStack()
        let sut = PaymentManagerUseCase(coreDataStack: mockCoreDataStack)
        //when
        let paymentData = sut.fetchAllData()
        //then
        XCTAssertNotNil(paymentData)
        XCTAssertGreaterThan(paymentData.count, 0)
    }
}
