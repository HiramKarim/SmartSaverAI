//
//  PaymentManagerVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import Combine

class RegisterPaymentVM: ObservableObject {
    
    private var currentUUIDForUpdatingDTO: UUID = .init()
    
    @Published var isLoading: Bool = false
    @Published var showSuccessRegistry:Bool = false
    @Published var showErrorOnRegistry:Bool = false
    @Published var isSelectedAsRecurring: Bool = false
    
    @Published internal var paymentName: String = ""
    @Published internal var paymentType: String = "Income"
    @Published internal var paymentDate: Date = Date()
    @Published internal var paymentAmount: String = ""
    @Published internal var paymentLocation: String = ""
    @Published internal var paymentMemo: String = ""
    @Published internal var selectedPaymentCategory: PaymentCategory = .other
    
    @Published var savedRegistrySuccessSubject = PassthroughSubject<Void, Never>()
    @Published private var savedRegistryerrorSubject = PassthroughSubject<Void, Never>()
    
    private let registerPaymentUseCase: RegisterPaymentUCProtocol
    private let registerRecurringPaymentUseCase: RegisterRecurringPaymentUCProtocol = RegisterRecurringPaymentUseCase()
    private let fetchRecurringPaymentUseCase: FetchRecurringPaymentUseCase = FetchRecurringPaymentUseCase()
    
    private var paymentDTO: PaymentRegistryDTO!
    
    private var registerSubject = PassthroughSubject<Void, Never>()
    private var registerRecurringPaymentSubject = PassthroughSubject<Void, Never>()
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
                if self.isSelectedAsRecurring {
                    self.registerRecurringPaymentSubject.send()
                } else {
                    self.isLoading = false
                    self.resetData()
                    self.showSuccessRegistry.toggle()
                    self.savedRegistrySuccessSubject.send()
                }
            })
            .store(in: &cancellables)
        
        registerRecurringPaymentSubject
            .flatMap { self.registerRecurringPaymentUseCase.savePayment(payment: self.paymentDTO,
                                                                        frecuency: "Montly",
                                                                        endDate: self.paymentDTO.date) }
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
                self.isLoading = false
                self.resetData()
                self.showSuccessRegistry = true
                self.savedRegistrySuccessSubject.send()
                self.isSelectedAsRecurring = false
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
        
        paymentDTO = PaymentRegistryDTO(
            id: UUID(),
            name: paymentName,
            memo: paymentMemo,
            date: paymentDate,
            amount: Double(paymentAmount) ?? 0.0,
            address: paymentLocation,
            typeNum: CategoryFormatter.getPaymentCategory(selectedPaymentCategory: selectedPaymentCategory),
            paymentType: getPaymentType(paymentType: paymentType)
        )
        registerSubject.send()
    }
    
    private func getPaymentType(paymentType: String) -> Int32 {
        return paymentType == "Income" ? 1 : 2
    }
    
    internal func updateViewForUpdate(paymentRegistry: PaymentRegistryDTO) {
        currentUUIDForUpdatingDTO = paymentRegistry.id
        paymentName = paymentRegistry.name
        paymentType = (paymentRegistry.paymentType == 1 ? "Income" : "Expence")
        paymentDate = paymentRegistry.date
        paymentAmount = "\(Double(paymentRegistry.amount))"
        paymentLocation = paymentRegistry.address ?? ""
        paymentMemo = paymentRegistry.memo ?? ""
        selectedPaymentCategory = CategoryFormatter.getPaymentCategoryByNumber(categoryNumber: paymentRegistry.typeNum)
        
        guard let recurringData = fetchRecurringPaymentUseCase.fetchRecurringPayments(forPayment: paymentRegistry).first
        else {
            return
        }
        
        if recurringData.paymentActivity != nil {
            isSelectedAsRecurring = true
        } else {
            isSelectedAsRecurring = false
        }
    }
    
    internal func getUpdatedPaymentRegistryDTO() -> PaymentRegistryDTO {
        return PaymentRegistryDTO(
            id: currentUUIDForUpdatingDTO,
            name: paymentName,
            memo: paymentMemo,
            date: paymentDate,
            amount: Double(paymentAmount) ?? 0.0,
            address: paymentLocation,
            typeNum: CategoryFormatter.getPaymentCategory(selectedPaymentCategory: selectedPaymentCategory),
            paymentType: getPaymentType(paymentType: paymentType)
        )
    }
    
}
