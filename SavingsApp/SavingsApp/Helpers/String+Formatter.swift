//
//  String+Formatter.swift
//  SavingsApp
//
//  Created by Hiram Castro on 27/05/24.
//

import Foundation

extension String {
    func convertToDate(usingFormat format: DateFormat = .monthAndYear) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: self)
    }
}
