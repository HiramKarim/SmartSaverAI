//
//  PersistenceModuleTests.swift
//  PersistenceModuleTests
//
//  Created by Hiram Castro on 28/03/24.
//

import XCTest
import CoreData
@testable import PersistenceModule

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

    func saveContext (payment: PaymentActivityDTO, 
                      completion: @escaping (Bool, NSError?) -> Void
    ) {
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

    func deleteObject(_ object: NSManagedObject, 
                      completion: @escaping (Bool, NSError?
                      ) -> Void) {
        let context = persistentContainer.viewContext
        context.delete(object)
        do {
            try context.save()
            completion(true, nil)
        } catch {
            context.rollback()
            let nserror = error as NSError
            completion(false, nserror)
        }
    }
    
    func fetchPayments(
        withName name: String? = nil
    ) -> [PaymentActivity] {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        if let name = name {
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        }
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Error al recuperar pagos: \(error.localizedDescription)")
            return []
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
    
    func fetchPayments(withName name: String? = nil) -> [PaymentActivityDTO] {
        let payments = self.coreDataStack.fetchPayments(withName: name)
        return convertToDTO(payments: payments)
    }
    
    func deletePayment(withName name: String? = nil, completion: @escaping (Bool, NSError?) -> Void) {
        let payments = self.coreDataStack.fetchPayments(withName: name)
        guard let payment = payments.first else {
            completion(false, nil)
            return
        }
        self.coreDataStack.deleteObject(payment, completion: completion)
    }
    
    private func convertToDTO(payments:[PaymentActivity]) -> [PaymentActivityDTO] {
        return payments.compactMap { paymentActivity in
            PaymentActivityDTO(id: paymentActivity.paymentId ?? UUID(),
                               name: paymentActivity.name ?? "",
                               memo: paymentActivity.memo ?? "",
                               date: paymentActivity.date ?? Date(),
                               amount: paymentActivity.amount,
                               address: paymentActivity.address ?? "",
                               typeNum: paymentActivity.typeNum)
        }
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
        
        let paymentRentBillDTO = PaymentActivityDTO(id: UUID(),
                                            name: "Rent bill",
                                            memo: "just for test",
                                            date: Date(),
                                            amount: Double(20000),
                                            address: "Condesa",
                                            typeNum: Int32(1))
        
        let paymentGasBillDTO = PaymentActivityDTO(id: UUID(),
                                            name: "Gas bill",
                                            memo: "just for test",
                                            date: Date(),
                                            amount: Double(500),
                                            address: "Condesa",
                                            typeNum: Int32(2))
        
        let exp_1 = expectation(description: "wait for completion")
        let exp_2 = expectation(description: "wait for completion")
        let exp_3 = expectation(description: "wait for completion")
        
        var result:Bool = false
        var result_2:Bool = false
        var result_3:Bool = false

        //when
        sut.saveData(payment: paymentRentBillDTO) { success, error in
            result = success
            exp_1.fulfill()
        }
        
        sut.saveData(payment: paymentGasBillDTO) { success, error in
            result_2 = success
            exp_2.fulfill()
        }
        
        sut.deletePayment(withName: "Gas bill") { success, error in
            result_3 = success
            exp_3.fulfill()
        }
        
        let paymentData = sut.fetchPayments()
        let rentPayment = sut.fetchPayments(withName: "Rent bill")
        let gasPayment = sut.fetchPayments(withName: "Gas bill")

        wait(for: [exp_1, exp_2, exp_3], timeout: 1.0)
        
        //then
        
        XCTAssertTrue(result)
        XCTAssertTrue(result_2)
        XCTAssertTrue(result_3)
        
        XCTAssertGreaterThan(paymentData.count, 0)
        XCTAssertNotNil(rentPayment)
        XCTAssertTrue(gasPayment.isEmpty)
    }
}
