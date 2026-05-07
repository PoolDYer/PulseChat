//
//  Date+Format.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

	
import Foundation

extension Date {

    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    func formattedFull() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
