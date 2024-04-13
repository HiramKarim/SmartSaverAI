//
//  CalendarSectionVM.swift
//  SavingsApp
//
//  Created by Hiram Castro on 12/04/24.
//

import Foundation
import SwiftUI

class CalendarSectionVM: ObservableObject {
    
    internal var currentDate = Date()
    @Published internal var dateText = String()
    
    internal func getCurrentDateFormatted() {
        dateText = currentDate.convertToString()
    }
    
    internal func alterMonth(using numberOfMonths: Int = 1) {
        let (newText, newDate) = self.currentDate.alterCurrentDateInMonth(using: numberOfMonths)
        self.dateText = newText
        self.currentDate = newDate!
    }
}
