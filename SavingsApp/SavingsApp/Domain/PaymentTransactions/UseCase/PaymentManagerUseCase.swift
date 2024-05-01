//
//  PaymentManagerUseCase.swift
//  SavingsApp
//
//  Created by Hiram Castro on 01/05/24.
//

import Foundation
import PersistenceModule

class PaymentManagerUseCase {
    internal enum PersistenceResult {
        case success([PaymentActivityDTO]?)
        case failure(Error?)
    }
    
    private let coreDataManager: CoreDataProtocol

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
        self.coreDataManager.savePayment(payment: payment) { result in
            switch result {
            case .success(let data): completion(.success(nil))
            case .failure(let error): completion(.failure(error))
            @unknown default:
                fatalError("")
            }
        }
    }
    
    func fetchPayments(withName name: String?, limit: Int?, completion: @escaping (PersistenceResult) -> Void) {
        self.coreDataManager.fetchPayments(withName: name, limit: limit) { [weak self] result in
            guard let self = self else { return }
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
    
    func fetchPayments(forMonth month: Int, year: Int, limit: Int?, completion: @escaping (PersistenceResult) -> Void) {
        self.coreDataManager.fetchPayments(forMonth: month, year: year, limit: limit) { [weak self] result in
            guard let self = self else { return }
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
    
    func deletePayment(withName name: String?, completion: @escaping (PersistenceResult) -> Void) {
        
    }
}
