//
//  FetchPaymentByDateVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 04/05/24.
//

import Foundation
import Combine


class FetchPaymentByDateVM: ObservableObject {
    @Published var dataPaymentArray = [PaymentRegistryDTO]()
    
    private var cancellables = Set<AnyCancellable>()
    let fetchPaymentsByDateUseCase:FetchPaymentByDateContract
    
    init(fetchPaymentsByDateUseCase: FetchPaymentByDateContract) {
        self.fetchPaymentsByDateUseCase = fetchPaymentsByDateUseCase
    }
    
    func fetchPayments(forMonth month: Int, 
                       year: Int,
                       limit: Int?) {
        
        self.fetchPaymentsByDateUseCase.fetchPayments(forMonth: month,
                                                      year: year,
                                                      limit: nil) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                guard let data = data else {
                    self.dataPaymentArray = []
                    return
                }
                self.dataPaymentArray = data.compactMap({ paymentDTO in
                    PaymentRegistryDTO.init(id: paymentDTO.id,
                                            name: paymentDTO.name,
                                            memo: paymentDTO.memo,
                                            date: paymentDTO.date,
                                            amount: paymentDTO.amount,
                                            address: paymentDTO.address,
                                            typeNum: paymentDTO.typeNum,
                                            paymentType: paymentDTO.paymentType)
                })
            case .failure(_): break
            }
        }
    }
}
