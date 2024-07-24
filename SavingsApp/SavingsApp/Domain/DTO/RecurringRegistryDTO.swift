//
//  RecurringRegistryDTO.swift
//  SavingsApp
//
//  Created by Hiram Castro on 23/07/24.
//

import Foundation

public struct RecurringPaymentDTO: Hashable {
    public var recurringID: UUID
    public var frequency: String
    public var endDate: Date
    public var paymentActivity: PaymentRegistryDTO
}
