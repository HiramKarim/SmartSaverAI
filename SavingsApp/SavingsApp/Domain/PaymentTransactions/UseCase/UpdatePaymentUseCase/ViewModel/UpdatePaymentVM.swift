//
//  UpdatePaymentVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 17/06/24.
//

import Foundation
import Combine

class UpdatePaymentVM: ObservableObject {
    
    @Published var showError: Bool = false
    @Published var paymentUpdated: Bool = false
    
    let useCase: UpdatePaymentUCProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: UpdatePaymentUCProtocol) {
        self.useCase = useCase
    }
    
    func updatePaymentRegistry(payment: PaymentRegistryDTO) {
        self.useCase.updatePayment(withPayment: payment)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                // Handle error if needed
                guard let self = self else { return }
                self.showError.toggle()
            } receiveValue: { [weak self] success in
                // Handle success
                guard let self = self else { return }
                self.paymentUpdated.toggle()
            }
            .store(in: &cancellables)
    }
    
}
