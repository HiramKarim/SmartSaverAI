//
//  FetchPaymentByDate.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule

protocol FetchPaymentByDateContract {
    func fetchPayments(forMonth month: Int, year: Int, limit: Int?, completion: @escaping (PaymentTransactionBase.PersistenceResult) -> Void)
}

class FetchPaymentByDate: PaymentTransactionBase {
    override init(coreDataManager: CoreDataProtocol = CoreDataManager.shared) {
        super.init(coreDataManager: coreDataManager)
    }
}

extension FetchPaymentByDate: FetchPaymentByDateContract {
    func fetchPayments(forMonth month: Int, year: Int, limit: Int?, completion: @escaping (PaymentTransactionBase.PersistenceResult) -> Void) {
        concurrentQueue.async {
            self.coreDataManager.fetchPayments(forMonth: month, year: year, limit: limit) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        guard let payments = data else {
                            completion(.failure(NSError(domain: "Cannot parse data", code: 0)))
                            return
                        }
                        completion(.success(payments))
                    case .failure(let error): completion(.failure(error))
                    @unknown default:
                        fatalError("")
                    }
                }
            }
        }
    }
}
