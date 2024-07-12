//
//  RecurringPaymentDTO.swift
//  PersistenceModule
//
//  Created by Hiram Castro on 11/07/24.
//

import Foundation

public struct RecurringPaymentDTO: Hashable {
    public var recurringID: UUID
    public var frequency: String
    public var endDate: Date
    public var paymentActivity: PaymentActivityDTO
}
