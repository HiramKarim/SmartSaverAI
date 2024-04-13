//
//  Date+Formatter.swift
//  SavingsApp
//
//  Created by Hiram Castro on 12/04/24.
//

import Foundation

extension Date {
    
    func convertToString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, YYYY"
        formatter.locale = .current
        
        return formatter.string(from: self)
    }
    
    func alterCurrentDateInMonth(using numberOfMonths: Int = 1) -> (String, Date?) {
        var dateComponent = DateComponents()
        dateComponent.month = numberOfMonths
        let futureDate  = Calendar.current.date(byAdding: dateComponent, to: self)
        
        return (futureDate?.convertToString() ?? "", futureDate)
    }
}
