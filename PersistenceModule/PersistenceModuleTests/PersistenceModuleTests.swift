//
//  PersistenceModuleTests.swift
//  PersistenceModuleTests
//
//  Created by Hiram Castro on 28/03/24.
//

import XCTest
import CoreData
@testable import PersistenceModule

class MockCoreDataLayer: CoreDataLayer {
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

class CoreDataLayer {
    static let shared = CoreDataLayer()

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
                      completion: @escaping (Bool, NSError?) -> Void) {
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
    
    func saveAndGetPaymentContext(payment: PaymentActivityDTO,
                                  completion: @escaping (PaymentActivity?, NSError?) -> Void) {
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
                completion(paymentInfo, nil)
            } catch {
                let nserror = error as NSError
                completion(nil, nserror)
            }
        }
    }
    
    func saveRecurringPaymentContext(payment: PaymentActivity,
                                     frequency: String, 
                                     endDate: Date,
                                     completion: @escaping (Bool, NSError?) -> Void) {
        let context = persistentContainer.viewContext
        let recurringPayment = RecurringPayment(context: context)
        var currentDate = payment.date ?? Date()
        
        recurringPayment.recurringID = UUID()
        recurringPayment.frequency = frequency
        recurringPayment.endDate = endDate
        
        let updatedPayment = PaymentActivity(context: context)
        updatedPayment.paymentId = payment.paymentId
        updatedPayment.paymentType = payment.paymentType
        updatedPayment.typeNum = payment.typeNum
        updatedPayment.name = payment.name
        updatedPayment.memo = payment.memo
        updatedPayment.date = currentDate
        updatedPayment.amount = payment.amount
        updatedPayment.address = payment.address
        
        recurringPayment.paymentActivity = updatedPayment
        
        switch frequency {
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
    
    func fetchRecurringPayments(forPayment paymentDTO: PaymentActivityDTO? = nil) -> [RecurringPayment] {
        let fetchRequest: NSFetchRequest<RecurringPayment> = RecurringPayment.fetchRequest()
        if let payment = paymentDTO {
            if let paymentActivity = fetchPayments(withName: payment.name).first {
                fetchRequest.predicate = NSPredicate(format: "paymentActivity == %@", paymentActivity)
            } else {
                return []
            }
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
    let coreDataLayer: CoreDataLayer

    init(coreDataStack: CoreDataLayer = CoreDataLayer.shared) {
        self.coreDataLayer = coreDataStack
    }

    func saveData(payment: PaymentActivityDTO, completion: @escaping (Bool, NSError?) -> Void) {
        self.coreDataLayer.saveContext(payment: payment) { success, error in
            completion(success, error)
        }
    }
    
    func saveRecurringPayment(payment: PaymentActivityDTO,
                              frecuency: String,
                              endDate: Date,
                              completion: @escaping (Bool, NSError?) -> Void) {
        coreDataLayer.saveAndGetPaymentContext(payment: payment) { [weak self] payment, error in
            guard let self = self else { return }
            if let payment = payment {
                self.coreDataLayer.saveRecurringPaymentContext(payment: payment,
                                                               frequency: frecuency,
                                                               endDate: endDate) { success, error in
                    completion(success, error)
                }
            } else {
                completion(false, NSError(domain: "cannot save payment", code: 0))
            }
        }
    }
    
    func updatePayment(payment: PaymentActivityDTO, completion: @escaping (Bool, NSError?) -> Void) {
        self.coreDataLayer.updatePayment(payment: payment) { success, error in
            completion(success, error)
        }
    }
    
    func fetchPayments(withName name: String? = nil) -> [PaymentActivityDTO] {
        let payments = self.coreDataLayer.fetchPayments(withName: name)
        return convertToDTO(payments: payments)
    }
    
    func fetchPayments(for month: Int, year: Int) -> [PaymentActivityDTO] {
        let payments = self.coreDataLayer.fetchPayments(for: month, year: year)
        return convertToDTO(payments: payments)
    }
    
    func deletePayment(withName name: String? = nil, completion: @escaping (Bool, NSError?) -> Void) {
        let payments = self.coreDataLayer.fetchPayments(withName: name)
        guard let payment = payments.first else {
            completion(false, nil)
            return
        }
        self.coreDataLayer.deleteObject(payment, completion: completion)
    }
    
    func fetchRecurringPayments(forPayment payment: PaymentActivityDTO? = nil) -> [RecurringPaymentDTO] {
        let recurringPayments = coreDataLayer.fetchRecurringPayments(forPayment: payment)
        if recurringPayments.isEmpty {
            return []
        } else {
            return convertRecurringPaymentsToDTO(recurringPayments: recurringPayments)
        }
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


class EmployeeCoreDataInteractorTests: XCTestCase {
    var mockCoreDataStack: MockCoreDataLayer!
    var sut: PaymentManagerUseCase!
    
    override func setUpWithError() throws {
        super.setUp()
        self.mockCoreDataStack = MockCoreDataLayer()
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
    
    func testSaveRecurringPayment() {
        // Given
        let paymentRentBillDTO = Utils.createPaymentDTO()
        var result:Bool = false
        var errorInsert:NSError? = nil
        
        let exp_1 = expectation(description: "wait for completion")
        
        // When
        sut.saveRecurringPayment(payment: paymentRentBillDTO,
                                 frecuency: "Montly",
                                 endDate: Date()) { success, error in
            
            result = success
            errorInsert = error
            
            exp_1.fulfill()
        }
        
        wait(for: [exp_1], timeout: 1.0)
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(errorInsert)
    }
    
    func testFetchRecurringPayments() {
        // Given
        let paymentRentBillDTO = Utils.createPaymentDTO()
        var result:Bool = false
        var errorInsert:NSError? = nil
        
        let exp_1 = expectation(description: "wait for completion")
        
        // When
        sut.saveRecurringPayment(payment: paymentRentBillDTO,
                                 frecuency: "Montly",
                                 endDate: Date()) { success, error in
            
            result = success
            errorInsert = error
            
            exp_1.fulfill()
        }
        
        wait(for: [exp_1], timeout: 1.0)
        
        let recurringPayments = sut.fetchRecurringPayments()
        
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(errorInsert)
        XCTAssertGreaterThan(recurringPayments.count, 0)
    }
    
    /*
    func testFetchRecurringPaymentsWithPaymentActivity() {
        // Given
        let paymentRentBillDTO = Utils.createPaymentDTO()
        var result:Bool = false
        var errorInsert:NSError? = nil
        
        let exp_1 = expectation(description: "wait for completion")
        
        // When
        sut.saveRecurringPayment(payment: paymentRentBillDTO,
                                 frecuency: "Montly",
                                 endDate: Date()) { success, error in
            
            result = success
            errorInsert = error
            
            exp_1.fulfill()
        }
        
        wait(for: [exp_1], timeout: 1.0)
        
        let recurringPayments = sut.fetchRecurringPayments(forPayment: paymentRentBillDTO)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(errorInsert)
        XCTAssertGreaterThan(recurringPayments.count, 0)
    }
    */
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
