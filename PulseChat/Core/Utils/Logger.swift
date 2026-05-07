//
//  Logger.swift
//  PulseChat
//

import Foundation

enum Logger {

    static func log(_ message: String) {
        #if DEBUG
        print("[LOG]: \(message)")
        #endif
    }

    static func error(_ message: String) {
        #if DEBUG
        print("[ERROR]: \(message)")
        #endif
    }
}
