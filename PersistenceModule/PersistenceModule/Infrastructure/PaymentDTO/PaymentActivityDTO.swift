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
}
