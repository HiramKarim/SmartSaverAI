//
//  FetchPaymentByDateVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 04/05/24.
//

import Foundation
import PersistenceModule
import Combine


class FetchPaymentByDateVM: ObservableObject {
    @Published var dataPaymentArray = [PaymentActivityDTO]()
    
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    let fetchPaymentsByDateUseCase:FetchPaymentByDateContract
    
    init(fetchPaymentsByDateUseCase: FetchPaymentByDateContract) {
        self.fetchPaymentsByDateUseCase = fetchPaymentsByDateUseCase
    }
    
    func fetchPayments(forMonth month: Int, 
                       year: Int,
                       limit: Int?) {
        
        let currentDate = Date()
        let month = calendar.component(.month, from: currentDate)
        let year = calendar.component(.year, from: currentDate)
        
        self.fetchPaymentsByDateUseCase.fetchPayments(forMonth: month,
                                                      year: year,
                                                      limit: nil) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                guard let data = data else {
                    return
                }
                self.dataPaymentArray = data
            case .failure(_): break
            }
        }
    }
}
