//
//  FetchCategoryPaymentsVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 05/08/24.
//

import Foundation
import Combine

struct categoryExpense: Identifiable {
    let id = UUID()
    let category:String
    let amount:Double
}

class FetchCategoryPaymentsVM: ObservableObject {
    @Published var categoryExpenses = [categoryExpense]()
    
    private var dataPaymentArray = [PaymentRegistryDTO]()
    
    private let useCase: FetchPaymentByDateContract
    
    init(useCase: FetchPaymentByDateContract) {
        self.useCase = useCase
    }
}

extension FetchCategoryPaymentsVM: fetchPaymentsProtocol {
    internal func fetchPayments(forMonth month: Int, year: Int, limit: Int?) {
        self.useCase.fetchPayments(forMonth: month,
                                   year: year,
                                   limit: nil) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                
                guard let data = data else {
                    self.dataPaymentArray = []
                    return
                }
                
                if !self.dataPaymentArray.isEmpty {
                    self.dataPaymentArray.removeAll()
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
                
                self.generateCategories()
            case .failure(_):
                break
            }
        }
    }
    
    internal func generateCategories() {
        var categoriesDict = [String:Double]()
        
        for payment in dataPaymentArray {
            let category = CategoryFormatter.getPaymentCategoryByNumber(categoryNumber: payment.typeNum).rawValue
            let amount:Double = payment.amount
            
            if categoriesDict[category] == nil {
                categoriesDict[category] = amount
            } else {
                let currentAmount:Double = categoriesDict[category] ?? 0.0
                let newAmount = currentAmount + amount
                categoriesDict[category] = newAmount
            }
        }
        
        categoryExpenses = categoriesDict.compactMap({ key, value in
                .init(category: key, amount: value)
        })
    }
}
