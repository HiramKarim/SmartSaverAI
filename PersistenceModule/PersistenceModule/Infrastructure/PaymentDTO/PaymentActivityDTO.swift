//
//  PaymentActivityDTO.swift
//  PersistenceModule
//
//  Created by Hiram Castro on 16/04/24.
//

import Foundation

public struct PaymentActivityDTO {
    let id:UUID
    let name:String
    let memo:String?
    let date:Date
    let amount:Double
    let address:String?
    let typeNum:Int32
    
    public init(id: UUID, 
                name: String,
                memo: String?,
                date: Date,
                amount: Double,
                address: String?,
                typeNum: Int32) {
        self.id = id
        self.name = name
        self.memo = memo
        self.date = date
        self.amount = amount
        self.address = address
        self.typeNum = typeNum
    }
}
