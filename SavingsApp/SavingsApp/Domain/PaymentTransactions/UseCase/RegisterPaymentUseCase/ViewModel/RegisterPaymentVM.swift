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
    
    @Published var isLoading: Bool = false
    @Published var showSuccessRegistry:Bool = false
    @Published var showErrorOnRegistry:Bool = false
    
    @Published internal var paymentName: String = ""
    @Published internal var paymentType: String = "Income"
    @Published internal var paymentDate: Date = Date()
    @Published internal var paymentAmount: String = ""
    @Published internal var paymentLocation: String = ""
    @Published internal var paymentMemo: String = ""
    @Published internal var selectedPaymentCategory: PaymentCategory = .other
    
    @Published var savedRegistrySuccessSubject = PassthroughSubject<Void, Never>()
    @Published var savedRegistryerrorSubject = PassthroughSubject<Void, Never>()
    
    private let registerPaymentUseCase: RegisterPaymentUCProtocol
    private var paymentDTO: PaymentActivityDTO!
    
    private var registerSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(registerPaymentUseCase: RegisterPaymentUCProtocol) {
        self.registerPaymentUseCase = registerPaymentUseCase
        
        registerSubject
            .flatMap { registerPaymentUseCase.savePayment(payment: self.paymentDTO) }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // Handle error if needed
                guard let self = self else { return }
                isLoading = false
                switch completion {
                case .finished: 
                    self.resetData()
                case .failure(_):
                    self.resetData()
                    self.showErrorOnRegistry.toggle()
                    self.savedRegistryerrorSubject.send()
                }
            }, receiveValue: { [weak self] result in
                // Handle success
                guard let self = self else { return }
                isLoading = false
                self.resetData()
                self.showSuccessRegistry.toggle()
                self.savedRegistrySuccessSubject.send()
            })
            .store(in: &cancellables)
            
    }
    
    private func resetData() {
        paymentName = ""
        paymentType = "Income"
        paymentDate = Date()
        paymentAmount = ""
        paymentLocation = ""
        paymentMemo = ""
        selectedPaymentCategory = .other
    }
    
    internal func registerPayment() {
        isLoading = true
        
        paymentDTO = PaymentActivityDTO(id: UUID(),
                                        name: paymentName,
                                        memo: paymentMemo,
                                        date: paymentDate,
                                        amount: Double(paymentAmount) ?? 0.0,
                                        address: paymentLocation,
                                        typeNum: getPaymentType(paymentType: paymentType),
                                        paymentType: getPaymentCategory(selectedPaymentCategory: selectedPaymentCategory))
        registerSubject.send()
    }
    
    private func getPaymentType(paymentType: String) -> Int32 {
        return paymentType == "Income" ? 1 : 2
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
