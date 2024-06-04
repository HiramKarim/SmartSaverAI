//
//  Date+Formatter.swift
//  SavingsApp
//
//  Created by Hiram Castro on 12/04/24.
//

import Foundation

enum DateFormat:String {
    case monthAndYear = "MMMM, yyyy"
    case fullDate = "dd MMMM yyyy"
}

extension Date {
    
    func convertToString(withFormat format: DateFormat = .monthAndYear) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: self)
    }
    
    func alterCurrentDateInMonth(using numberOfMonths: Int = 1) -> (String, Date?) {
        var dateComponent = DateComponents()
        dateComponent.month = numberOfMonths
        let futureDate  = Calendar.current.date(byAdding: dateComponent, to: self)
        return (futureDate?.convertToString() ?? "", futureDate)
    }
}


