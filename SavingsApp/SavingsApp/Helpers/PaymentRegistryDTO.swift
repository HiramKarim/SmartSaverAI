//
//  PaymentRegistryDTO.swift
//  SavingsApp
//
//  Created by Hiram Castro on 05/05/24.
//

import Foundation

public struct PaymentRegistryDTO: Hashable {
    public let id:UUID
    public var name:String
    public var memo:String?
    public var date:Date
    public var amount:Double
    public var address:String?
    public var typeNum:Int32
    public var paymentType:Int32
    
    public init(id: UUID = UUID(),
                name: String = "",
                memo: String? = "",
                date: Date = Date(),
                amount: Double = 0.0,
                address: String? = "",
                typeNum: Int32 = 2,
                paymentType:Int32 = 1) {
        self.id = id
        self.name = name
        self.memo = memo
        self.date = date
        self.amount = amount
        self.address = address
        self.typeNum = typeNum
        self.paymentType = paymentType
    }
}
