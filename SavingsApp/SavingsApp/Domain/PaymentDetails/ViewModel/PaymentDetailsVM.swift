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
    private let useCase:DeletePaymentContract
    
    init(deleteUseCase: DeletePaymentContract) {
        self.useCase = deleteUseCase
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
    
}
