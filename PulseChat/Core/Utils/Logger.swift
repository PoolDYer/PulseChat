//
//  Logger.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import Foundation

enum Logger {

    static func log(_ message: String) {
        #if DEBUG
        print("🟢 [LOG]: \(message)")
        #endif
    }

    static func error(_ message: String) {
        #if DEBUG
        print("🔴 [ERROR]: \(message)")
        #endif
    }
}
