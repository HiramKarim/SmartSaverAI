//
//  Category+Formatter.swift
//  SavingsApp
//
//  Created by Hiram Castro on 05/08/24.
//

import Foundation

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

final class CategoryFormatter {
    private init() {}
    
    internal static func getPaymentCategory(selectedPaymentCategory: PaymentCategory) -> Int32 {
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

    internal static func getPaymentCategoryByNumber(categoryNumber: Int32) -> PaymentCategory {
        switch categoryNumber {
        case 1: return .bank
        case 2: return .rent
        case 3: return .loan
        case 4: return .groseries
        case 5: return .taxBill
        case 6: return .gasBill
        case 7: return .other
        default:
            return .other
        }
    }

}
