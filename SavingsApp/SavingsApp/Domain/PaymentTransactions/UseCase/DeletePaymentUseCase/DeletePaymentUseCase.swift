//
//  DeletePaymentUseCase.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule

protocol DeletePaymentContract {
    func deletePayment(withName name: String?, completion: @escaping (PaymentTransactionBase.PersistenceResult) -> Void)
}

class DeletePaymentUseCase: PaymentTransactionBase {
    override init(coreDataManager: CoreDataProtocol = CoreDataManager.shared) {
        super.init(coreDataManager: coreDataManager)
    }
}

extension DeletePaymentUseCase: DeletePaymentContract {
    func deletePayment(withName name: String?, completion: @escaping (PaymentTransactionBase.PersistenceResult) -> Void) {
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
                                case .failure(_):
                                    completion(.failure(ErrorPersistence.DeletionError))
                                @unknown default:
                                    completion(.failure(ErrorPersistence.DeletionError))
                                }
                            }
                        }
                    case .failure(_): break
                    @unknown default:
                        completion(.failure(ErrorPersistence.DeletionError))
                    }
                }
            }
        }
    }
}
