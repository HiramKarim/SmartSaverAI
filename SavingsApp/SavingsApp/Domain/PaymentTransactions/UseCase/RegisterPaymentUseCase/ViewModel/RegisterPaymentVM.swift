//
//  PaymentManagerVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule
import Combine

enum PaymentCategory: String, Identifiable, CaseIterable {
    var id: Self { self }
    case bank = "Bank"
    case groseries = "Groseries"
    case rent = "Rent"
    case loan = "Loan"
    case taxBill = "Tax Bill"
    case gasBill = "Gas Bill"
    case other = "Other"
}

class RegisterPaymentVM: ObservableObject {
    
    @Published var showSuccessRegistry:Bool = false
    @Published var showErrorOnRegistry:Bool = false
    
    @Published private var paymentName: String = ""
    @Published private var paymentType: String = "Income"
    @Published private var paymentDate: Date = Date()
    @Published private var paymentAmount: String = ""
    @Published private var paymentLocation: String = ""
    @Published private var paymentMemo: String = ""
    @Published private var selectedPaymentCategory: PaymentCategory = .other
    
    private let registerPaymentUseCase: RegisterPaymentUCProtocol
    private var paymentDTO: PaymentActivityDTO!
    private var registerSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(registerPaymentUseCase: RegisterPaymentUCProtocol) {
        self.registerPaymentUseCase = registerPaymentUseCase
        
        registerSubject
            .flatMap { registerPaymentUseCase.savePayment(payment: self.paymentDTO) }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle completion if needed
            }, receiveValue: { result in
                
            })
            .store(in: &cancellables)
            
    }
    
    internal func registerPayment() {
        paymentDTO = PaymentActivityDTO(id: UUID(),
                                        name: paymentName,
                                        memo: paymentMemo,
                                        date: paymentDate,
                                        amount: Double(paymentAmount) ?? 0.0,
                                        address: paymentLocation,
                                        typeNum: getPaymentType(paymentType: paymentType),
                                        paymentType: getPaymentCategory(selectedPaymentCategory: selectedPaymentCategory))
        registerSubject.send()
        /*
        self.registerPaymentUseCase.savePayment(payment: paymentDTO) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_): self.showSuccessRegistry.toggle()
            case .failure(_): self.showErrorOnRegistry.toggle()
            }
        }
        */
    }
    
    private func getPaymentType(paymentType: String) -> Int32 {
        return paymentType == "payment" ? 1 : 2
    }
    
    private func getPaymentCategory(selectedPaymentCategory: PaymentCategory) -> Int32 {
        switch selectedPaymentCategory {
        case .bank: return 1
        case .rent: return 2
        case .loan: return 3
        case .groseries: return 4
        case .taxBill: return 5
        case .gasBill: return 6
        case .other: return 7
        }
    }
    
}
