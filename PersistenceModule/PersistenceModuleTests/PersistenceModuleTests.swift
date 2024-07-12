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

    func saveContext(payment: PaymentActivityDTO,
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
    
    func saveRecurringPaymentContext(payment: PaymentActivityDTO,
                                     recurrentPayment: RecurringPaymentDTO,
                                     frequency: String, 
                                     endDate: Date,
                                     completion: @escaping (Bool, NSError?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let paymentInfo = PaymentActivity(context: context)
        let recurringPayment = RecurringPayment(context: context)
        
        paymentInfo.paymentId = payment.id
        paymentInfo.name = payment.name
        paymentInfo.address = payment.address
        paymentInfo.amount = payment.amount
        paymentInfo.date = payment.date
        paymentInfo.memo = payment.memo
        paymentInfo.typeNum = payment.typeNum
        
        recurringPayment.recurringID = UUID()
        recurringPayment.frequency = frequency
        recurringPayment.endDate = endDate
        recurringPayment.paymentActivity = paymentInfo

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
    
    public func updatePayment(payment: PaymentActivityDTO,
                              completion: @escaping (Bool, NSError?) -> Void) {
        let fetchRequest: NSFetchRequest<PaymentActivity> = PaymentActivity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", payment.name as CVarArg)
        
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
                        completion(true, nil)
                    } catch {
                        let nserror = error as NSError
                        completion(false, nserror)
                    }
                }
            }
        } catch {
            let nserror = error as NSError
            completion(false, nserror)
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
    
    func updatePayment(payment: PaymentActivityDTO, completion: @escaping (Bool, NSError?) -> Void) {
        self.coreDataStack.updatePayment(payment: payment) { success, error in
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
                               typeNum: paymentActivity.typeNum, 
                               paymentType: paymentActivity.paymentType)
        }
    }
}


class EmployeeCoreDataInteractorTests: XCTestCase {
    var mockCoreDataStack: MockCoreDataStack!
    var sut: PaymentManagerUseCase!
    
    override func setUpWithError() throws {
        super.setUp()
        self.mockCoreDataStack = MockCoreDataStack()
        self.sut = PaymentManagerUseCase(coreDataStack: mockCoreDataStack)
    }
    
    override func tearDownWithError() throws {
        self.sut = nil
        self.mockCoreDataStack = nil
        super.tearDown()
    }
    
    func testSavePayment() {
        // Given
        let paymentRentBillDTO = Utils.createPaymentDTO()
        var result:Bool = false
        var errorInsert:NSError? = nil
        
        let exp_1 = expectation(description: "wait for completion")
        
        // When
        sut.saveData(payment: paymentRentBillDTO) { success, error in
            
            result = success
            errorInsert = error
            
            exp_1.fulfill()
        }
        
        wait(for: [exp_1], timeout: 1.0)
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(errorInsert)
    }
    
    func testUpdatePayment() {
        // Given
        let paymentRentBillDTO = Utils.createPaymentDTO()
        let newPaymentInfo = Utils.createNewPaymentDTO()
        
        var result:Bool = false
        var errorInsert:NSError? = nil
        
        var updateResult:Bool = false
        var updateErrorInsert:NSError? = nil
        
        let exp_1 = expectation(description: "insert - wait for completion")
        let exp_2 = expectation(description: "update - wait for completion")
        
        // When
        sut.saveData(payment: paymentRentBillDTO) { success, error in
            result = success
            errorInsert = error
            exp_1.fulfill()
        }
        
        sut.updatePayment(payment: newPaymentInfo) { success, error in
            updateResult = success
            updateErrorInsert = error
            exp_2.fulfill()
        }
        
        wait(for: [exp_1, exp_2], timeout: 5.0)
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(errorInsert)
        
        XCTAssertTrue(updateResult)
        XCTAssertNil(updateErrorInsert)
    }
    
    func testFetchAllPayments() {
        // Given
        let paymentRentBillDTO = Utils.createPaymentDTO()
        
        let exp_1 = expectation(description: "wait for completion")
        
        // When
        sut.saveData(payment: paymentRentBillDTO) { _, _ in
            exp_1.fulfill()
        }
        
        wait(for: [exp_1], timeout: 1.0)
        
        let paymentData = sut.fetchPayments()
        
        // Then
        XCTAssertGreaterThan(paymentData.count, 0)
    }
    
    func testFetchPaymentsByName() {
        // Given
        let currentPaymentBillDTO = Utils.createPaymentDTO()
        let pastPaymentBillDTO = Utils.createPastPaymentDTO()
        
        let exp_1 = expectation(description: "wait for completion")
        let exp_2 = expectation(description: "wait for completion")
        
        // When
        sut.saveData(payment: currentPaymentBillDTO) { _, _ in
            exp_1.fulfill()
        }
        
        sut.saveData(payment: pastPaymentBillDTO) { _, _ in
            exp_2.fulfill()
        }
        
        wait(for: [exp_1, exp_2], timeout: 1.0)
        
        let rentPayment = sut.fetchPayments(withName: "Rent bill")
        let gasPayment = sut.fetchPayments(withName: "Gas bill")
        
        // Then
        XCTAssertGreaterThan(rentPayment.count, 0)
        XCTAssertGreaterThan(gasPayment.count, 0)
    }
    
    func testFetchPaymentsByDateRange() {
        // Given
        let currentDate = Date()
        let calendar = Calendar.current
        let currentPaymentBillDTO = Utils.createPaymentDTO()
        let pastPaymentBillDTO = Utils.createPastPaymentDTO()
        
        let month = calendar.component(.month, from: currentDate)
        let year = calendar.component(.year, from: currentDate)
        
        let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        let prevMonth = calendar.component(.month, from: prevMonthDate)
        let prevYear = calendar.component(.year, from: prevMonthDate)
        
        let exp_1 = expectation(description: "wait for completion")
        let exp_2 = expectation(description: "wait for completion")
        
        // When
        sut.saveData(payment: currentPaymentBillDTO) { _, _ in
            exp_1.fulfill()
        }
        
        sut.saveData(payment: pastPaymentBillDTO) { _, _ in
            exp_2.fulfill()
        }
        
        wait(for: [exp_1, exp_2], timeout: 1.0)
        
        let paymentsOfCurrentMonth = sut.fetchPayments(for: month, year: year)
        let paymentsOfPastMonth = sut.fetchPayments(for: prevMonth, year: prevYear)
        
        
        // Then
        XCTAssertGreaterThan(paymentsOfCurrentMonth.count, 0)
        XCTAssertGreaterThan(paymentsOfPastMonth.count, 0)
    }
    
    func testDeletePayment() {
        // Given
        let paymentRentBillDTO = Utils.createPaymentDTO()
        let pastPaymentBillDTO = Utils.createPastPaymentDTO()
        
        let exp_1 = expectation(description: "wait for completion")
        let exp_2 = expectation(description: "wait for completion")
        let exp_3 = expectation(description: "wait for completion")
        var result:Bool = false
        var errorInsert:NSError? = nil
        
        // When
        sut.saveData(payment: paymentRentBillDTO) { _, _ in
            exp_1.fulfill()
        }
        
        sut.saveData(payment: pastPaymentBillDTO) { _, _ in
            exp_2.fulfill()
        }
        
        sut.deletePayment(withName: "Gas bill") { success, error in
            result = success
            errorInsert = error
            exp_3.fulfill()
        }
        
        wait(for: [exp_1, exp_2, exp_3], timeout: 1.0)
        
        let paymentData = sut.fetchPayments()
        
        // Then
        XCTAssertEqual(paymentData.count, 1)
        XCTAssertTrue(result)
        XCTAssertNil(errorInsert)
    }
}

class Utils {
    
    enum paymentCategory: Int32 {
        case Rent = 1
        case Gas = 2
    }
    
    enum paymentType: Int32 {
        case payment = 1
        case transaction = 2
    }
    
    lazy var prevMonth:Date = {
        let calendar = Calendar.current
        let currentDate = Date()
        let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        return prevMonthDate
    }()
    
    static func createPaymentDTO() -> PaymentActivityDTO {
        return PaymentActivityDTO(id: UUID(),
                                  name: "Rent bill",
                                  memo: "just for test",
                                  date: Date(),
                                  amount: Double(20000),
                                  address: "Condesa",
                                  typeNum: paymentCategory.Rent.rawValue,
                                  paymentType: paymentType.payment.rawValue)
    }
    
    static func createNewPaymentDTO() -> PaymentActivityDTO {
        return PaymentActivityDTO(id: UUID(),
                                  name: "Rent bill",
                                  memo: "just for update test",
                                  date: Date(),
                                  amount: Double(40000),
                                  address: "Condesa",
                                  typeNum: paymentCategory.Rent.rawValue,
                                  paymentType: paymentType.payment.rawValue)
    }
    
    static func createPastPaymentDTO() -> PaymentActivityDTO {
        return PaymentActivityDTO(id: UUID(),
                                  name: "Gas bill",
                                  memo: "just for test",
                                  date: Utils().prevMonth,
                                  amount: Double(500),
                                  address: "Condesa",
                                  typeNum: paymentCategory.Gas.rawValue,
                                  paymentType: paymentType.payment.rawValue)
    }
}
