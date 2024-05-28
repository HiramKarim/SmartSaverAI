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
    private let calendar = Calendar.current
    
    @Published internal var dateText = String()
    
    var month: Int = 1
    var year: Int = 1
    
    internal func getCurrentDateFormatted() {
        self.dateText = currentDate.convertToString()
        self.getCurrentDate()
    }
    
    internal func alterMonth(using numberOfMonths: Int = 1) {
        let (newText, newDate) = self.currentDate.alterCurrentDateInMonth(using: numberOfMonths)
        self.dateText = newText
        self.currentDate = newDate!
        self.getCurrentDate()
    }
    
    internal func convertDateSelectedOf(month:String, andYear year:String) {
        self.dateText = "\(month), \(year)"
        guard let currentDate = dateText.convertToDate() else {
            return
        }
        self.currentDate = currentDate
        self.getCurrentDate()
    }
    
    private func getCurrentDate() {
        self.month = calendar.component(.month, from: currentDate)
        self.year = calendar.component(.year, from: currentDate)
    }
}
