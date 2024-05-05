//
//  PaymentActivityDTO.swift
//  PersistenceModule
//
//  Created by Hiram Castro on 16/04/24.
//

import Foundation

public struct PaymentActivityDTO: Hashable {
    public let id:UUID
    public var name:String
    public var memo:String?
    public var date:Date
    public var amount:Double
    public var address:String?
    public var typeNum:Int32
    public var paymentType:Int32
    
    public init(id: UUID, 
                name: String,
                memo: String?,
                date: Date,
                amount: Double,
                address: String?,
                typeNum: Int32,
                paymentType:Int32) {
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
