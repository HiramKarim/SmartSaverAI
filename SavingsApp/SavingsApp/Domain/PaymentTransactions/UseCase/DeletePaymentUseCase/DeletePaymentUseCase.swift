//
//  DeletePaymentUseCase.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule
import Combine

protocol DeletePaymentContract {
    func deletePayment(withName name: String?) -> Future<Void, Error>
}

class DeletePaymentUseCase: PaymentTransactionBase {
    override init(coreDataManager: CoreDataProtocol = CoreDataManager.shared) {
        super.init(coreDataManager: coreDataManager)
    }
}

extension DeletePaymentUseCase: DeletePaymentContract {
    func deletePayment(withName name: String?) -> Future<Void, any Error> {
        return Future<Void, any Error> { [weak self] promise in
            guard let self = self else { return }
            self.concurrentQueue.async {
                self.coreDataManager.fetchPayments(withName: name, limit: nil) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let payments):
                        guard let payment = payments?.first else {
                            promise(.failure(ErrorPersistence.FetchError))
                            return
                        }
                        self.coreDataManager.deletePayment(forPayment: payment) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(_):
                                    promise(.success(()))
                                case .failure(_):
                                    promise(.failure(ErrorPersistence.DeletionError))
                                @unknown default:
                                    promise(.failure(ErrorPersistence.DeletionError))
                                }
                            }
                        }
                    case .failure(_):
                        promise(.failure(ErrorPersistence.FetchError))
                    @unknown default:
                        promise(.failure(ErrorPersistence.FetchError))
                    }
                }
            }
        }
    }
}
