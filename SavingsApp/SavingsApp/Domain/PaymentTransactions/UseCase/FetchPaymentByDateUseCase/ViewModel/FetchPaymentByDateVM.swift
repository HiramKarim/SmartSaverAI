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
    
    @Published var totalBalance: Double = 0
    @Published var totalIncome: Double = 0
    @Published var totalExpence: Double = 0
    
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
                
                self.calculateBalance(payments: self.dataPaymentArray)
            case .failure(_): break
            }
        }
    }
    
    private func calculateBalance(payments: [PaymentRegistryDTO]) {
        
        var totalBalance:Double = 0.0
        var totalIncome:Double = 0.0
        var totalExpence:Double = 0.0
        
        var expences = payments.filter({ payment in
            payment.typeNum == 2
        })
        
        var incomes = payments.filter({ payment in
            payment.typeNum == 1
        })
        
        for expence in expences {
            totalExpence += expence.amount
        }
        
        for income in incomes {
            totalIncome += income.amount
        }
        
        totalBalance = totalIncome - totalExpence
        
        self.totalBalance = totalBalance
        self.totalIncome = totalIncome
        self.totalExpence = totalExpence
    }
}
