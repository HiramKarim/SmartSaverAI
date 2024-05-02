//
//  PaymentManagerUseCase.swift
//  SavingsApp
//
//  Created by Hiram Castro on 01/05/24.
//

import Foundation
import PersistenceModule

class PaymentManagerUseCase {

    private enum ErrorPersistence: Error {
        case InsertionError
        case FetchError
        case DeletionError
        case InitCoreDataError
    }
    
    internal enum PersistenceResult {
        case success([PaymentActivityDTO]?)
        case failure(Error?)
    }
    
    private let coreDataManager: CoreDataProtocol
    private let concurrentQueue = DispatchQueue(label: "com.SmartSavings.coredata", attributes: .concurrent)

    init(coreDataManager: CoreDataProtocol = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
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

extension PaymentManagerUseCase {
    func savePayment(payment: PersistenceModule.PaymentActivityDTO, completion: @escaping (PersistenceResult) -> Void) {
        concurrentQueue.async {
            self.coreDataManager.savePayment(payment: payment) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_): completion(.success(nil))
                    case .failure(let error): completion(.failure(error))
                    @unknown default:
                        fatalError("")
                    }
                }
            }
        }
    }
    
    func fetchPayments(withName name: String?, limit: Int?, completion: @escaping (PersistenceResult) -> Void) {
        concurrentQueue.async {
            self.coreDataManager.fetchPayments(withName: name, limit: limit) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        guard let payments = data else {
                            completion(.failure(ErrorPersistence.FetchError))
                            return
                        }
                        completion(.success(self.convertToDTO(payments: payments)))
                    case .failure(let error): completion(.failure(ErrorPersistence.FetchError))
                    @unknown default:
                        fatalError("")
                    }
                }
            }
        }
    }
    
    func fetchPayments(forMonth month: Int, year: Int, limit: Int?, completion: @escaping (PersistenceResult) -> Void) {
        concurrentQueue.async {
            self.coreDataManager.fetchPayments(forMonth: month, year: year, limit: limit) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        guard let payments = data else {
                            completion(.failure(NSError(domain: "Cannot parse data", code: 0)))
                            return
                        }
                        completion(.success(self.convertToDTO(payments: payments)))
                    case .failure(let error): completion(.failure(error))
                    @unknown default:
                        fatalError("")
                    }
                }
            }
        }
    }
    
    func deletePayment(withName name: String?, completion: @escaping (PersistenceResult) -> Void) {
        concurrentQueue.async {
            self.coreDataManager.fetchPayments(withName: name, limit: nil) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async { 
                    switch result {
                    case .success(let payments):
                        guard let payment = payments?.first else {
                            completion(.failure(ErrorPersistence.FetchError))
                            return
                        }
                        self.coreDataManager.deletePayment(payment) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(_):
                                    completion(.success(nil))
                                case .failure(let error):
                                    completion(.failure(ErrorPersistence.DeletionError))
                                @unknown default:
                                    completion(.failure(ErrorPersistence.DeletionError))
                                }
                            }
                        }
                    case .failure(let error): break
                    @unknown default:
                        completion(.failure(ErrorPersistence.DeletionError))
                    }
                }
            }
        }
    }
}
