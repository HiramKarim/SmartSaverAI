//
//  PaymentDetailsVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 05/05/24.
//

import Foundation
import Combine

class PaymentDetailsVM: ObservableObject {
    
    @Published var name: String = ""
    @Published var date: Date = Date()
    @Published var location: String = ""
    @Published var memo: String = ""
    @Published var amount: Double = 0.0
    @Published var paymentType: Int32 = 1
    
    @Published var showError: Bool = false
    @Published var paymentDeleted: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let useCase: DeletePaymentContract
    private let fetchByNameUseCase: FetchPaymentByNameContract?
    
    init(deleteUseCase: DeletePaymentContract,
         fetchByNameUseCase: FetchPaymentByNameContract? = nil) {
        self.useCase = deleteUseCase
        self.fetchByNameUseCase = fetchByNameUseCase
    }
    
    func updateView(withPayment payment: PaymentRegistryDTO) {
        self.name = payment.name
        self.date = payment.date
        self.location = payment.address ?? ""
        self.memo = payment.memo ?? ""
        self.amount = payment.amount
        self.paymentType = payment.typeNum
    }
    
    func deletePayment() {
        self.useCase.deletePayment(withName: self.name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle error if needed
                guard let self = self else { return }
                self.showError.toggle()
            } receiveValue: { [weak self] result in
                // Handle success
                guard let self = self else { return }
                self.paymentDeleted.toggle()
            }
            .store(in: &cancellables)
    }
    
    func getPaymentData() {
        fetchByNameUseCase?.fetchPayments(withName: self.name, 
                                          limit: nil, completion: { 
            [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let paymentActivity):
                guard let paymentDTO = paymentActivity?.first else {
                    return
                }
                self.updateView(withPayment: .init(id: paymentDTO.id,
                                                   name: paymentDTO.name,
                                                   memo: paymentDTO.memo,
                                                   date: paymentDTO.date,
                                                   amount: paymentDTO.amount,
                                                   address: paymentDTO.address,
                                                   typeNum: paymentDTO.typeNum,
                                                   paymentType: paymentDTO.paymentType
                                                  )
                )
            case .failure(_): break
            }
        })
    }
    
}
