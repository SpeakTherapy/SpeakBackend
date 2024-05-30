//
//  File.swift
//  
//
//  Created by Tanish Bhowmick on 5/27/24.
//

import Foundation

struct DateUtils {
    static func getCurrentDate() -> Date {
        Date()
    }
    
    static func formatDate(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
