//
//  FetchPaymentByNameUseCase.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule

protocol FetchPaymentByNameContract {
    func fetchPayments(withName name: String?, limit: Int?, completion: @escaping (PaymentTransactionBase.PersistenceResult) -> Void)
}

class FetchPaymentByNameUseCase: PaymentTransactionBase {
    override init(coreDataManager: CoreDataProtocol = CoreDataManager.shared) {
        super.init(coreDataManager: coreDataManager)
    }
}

extension FetchPaymentByNameUseCase: FetchPaymentByNameContract {
    func fetchPayments(withName name: String?, limit: Int?, completion: @escaping (PaymentTransactionBase.PersistenceResult) -> Void) {
        concurrentQueue.async {
            self.coreDataManager.fetchPayments(withName: name, limit: limit) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        guard let payments = data else {
                            completion(.failure(ErrorPersistence.FetchError))
                            return
                        }
                        completion(.success(payments))
                    case .failure(_): completion(.failure(ErrorPersistence.FetchError))
                    @unknown default:
                        fatalError("")
                    }
                }
            }
        }
    }
}
