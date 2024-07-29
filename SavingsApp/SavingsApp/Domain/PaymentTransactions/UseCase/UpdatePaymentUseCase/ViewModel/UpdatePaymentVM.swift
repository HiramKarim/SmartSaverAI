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
    @Published var isSelectedAsRecurring: Bool = false
    
    let useCase: UpdatePaymentUCProtocol
    private let registerRecurringPaymentUseCase: RegisterRecurringPaymentUCProtocol = RegisterRecurringPaymentUseCase()
    
    private var cancellables = Set<AnyCancellable>()
    private var registerRecurringPaymentSubject = PassthroughSubject<Void, Never>()
    
    private var paymentDTO = PaymentRegistryDTO()
    
    init(useCase: UpdatePaymentUCProtocol) {
        self.useCase = useCase
    }
    
    func updatePaymentRegistry(payment: PaymentRegistryDTO) {
        self.paymentDTO = payment
        self.useCase.updatePayment(withPayment: payment)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                // Handle error if needed
                guard let self = self else { return }
                self.showError.toggle()
            } receiveValue: { [weak self] success in
                // Handle success
                guard let self = self else { return }
                if self.isSelectedAsRecurring {
                    self.registerRecurringPaymentSubject.send()
                } else {
                    self.paymentUpdated.toggle()
                }
            }
            .store(in: &cancellables)
        
        registerRecurringPaymentSubject
            .flatMap { self.registerRecurringPaymentUseCase.savePayment(payment: self.paymentDTO,
                                                                        frecuency: "Montly",
                                                                        endDate: self.paymentDTO.date) }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle error if needed
                
                switch completion {
                case .finished: break
                    
                case .failure(_): break
                    
                }
            }, receiveValue: { [weak self] result in
                // Handle success
                guard let self = self else { return }
                self.paymentUpdated.toggle()
                self.isSelectedAsRecurring = false
            })
            .store(in: &cancellables)
    }
    
}
