//
//  PaymentManagerVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 02/05/24.
//

import Foundation
import PersistenceModule

class PaymentManagerVM: ObservableObject {
    
    private let coreDataManager: CoreDataProtocol
    
    init(coreDataManager: CoreDataProtocol = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
}
