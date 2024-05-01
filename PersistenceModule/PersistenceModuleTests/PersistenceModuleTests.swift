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
    
    func fetchPayments(for month: Int, year: Int) -> [PaymentActivity] {
        let calendar = Calendar.current
        var startDateComponents = DateComponents()
        startDateComponents.year = year
        startDateComponents.month = month
        
        guard let startDate = calendar.date(from: startDateComponents) else {
            return []
        }
        
        guard let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else {
            return []
        }
        
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        fetchRequest.predicate = predicate
        
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
    
    func fetchPayments(for month: Int, year: Int) -> [PaymentActivityDTO] {
        let payments = self.coreDataStack.fetchPayments(for: month, year: year)
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
    /*
    func testCRUD() {
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
    */
    
    func testFetchDataByMonth() {
        //given
        let mockCoreDataStack = MockCoreDataStack()
        let sut = PaymentManagerUseCase(coreDataStack: mockCoreDataStack)
        let currentDate = Date()
        
        let paymentRentBillDTO = PaymentActivityDTO(id: UUID(),
                                                    name: "Rent bill",
                                                    memo: "just for test",
                                                    date: currentDate,
                                                    amount: Double(20000),
                                                    address: "Condesa",
                                                    typeNum: Int32(1))
        
        let paymentGasBillDTO = PaymentActivityDTO(id: UUID(),
                                                   name: "Gas bill",
                                                   memo: "just for test",
                                                   date: currentDate,
                                                   amount: Double(500),
                                                   address: "Condesa",
                                                   typeNum: Int32(2))
        
        let paymentCarServiceBillDTO = PaymentActivityDTO(id: UUID(),
                                                          name: "Car service bill",
                                                          memo: "just for test",
                                                          date: Utils().prevMonth,
                                                          amount: Double(17500),
                                                          address: "Condesa",
                                                          typeNum: Int32(3))
        
        let paymentGpsBillDTO = PaymentActivityDTO(id: UUID(),
                                                   name: "GPS bill",
                                                   memo: "just for test",
                                                   date: Utils().prevMonth,
                                                   amount: Double(200),
                                                   address: "Condesa",
                                                   typeNum: Int32(5))
        
        let exp_1 = expectation(description: "wait for completion")
        let exp_2 = expectation(description: "wait for completion")
        let exp_3 = expectation(description: "wait for completion")
        let exp_4 = expectation(description: "wait for completion")
        
        var result:Bool = false
        var result_2:Bool = false
        var result_3:Bool = false
        var result_4:Bool = false

        //when
        sut.saveData(payment: paymentRentBillDTO) { success, error in
            result = success
            exp_1.fulfill()
        }
        
        sut.saveData(payment: paymentGasBillDTO) { success, error in
            result_2 = success
            exp_2.fulfill()
        }
        
        sut.saveData(payment: paymentCarServiceBillDTO) { success, error in
            result_3 = success
            exp_3.fulfill()
        }
        
        sut.saveData(payment: paymentGpsBillDTO) { success, error in
            result_4 = success
            exp_4.fulfill()
        }
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: currentDate)
        let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        let prevMonth = calendar.component(.month, from: prevMonthDate)
        
        let paymentData = sut.fetchPayments()
        let paymentsOfCurrentMonth = sut.fetchPayments(for: month, year: 2024)
        let paymentsOfPastMonth = sut.fetchPayments(for: prevMonth, year: 2024)

        wait(for: [exp_1, exp_2, exp_3, exp_4], timeout: 1.0)
        
        //then
        
        XCTAssertTrue(result)
        XCTAssertTrue(result_2)
        XCTAssertTrue(result_3)
        XCTAssertTrue(result_4)
        
        XCTAssertGreaterThan(paymentData.count, 0)
        XCTAssertGreaterThan(paymentsOfCurrentMonth.count, 0)
        XCTAssertGreaterThan(paymentsOfPastMonth.count, 0)
    }
}

class Utils {
    lazy var prevMonth:Date = {
        let calendar = Calendar.current
        let currentDate = Date()
        let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        return prevMonthDate
    }()
}
