//
//  EmptyStateView.swift
//  PulseChat
//

import SwiftUI

struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack {
            Text(message)
                .foregroundColor(.gray)
        }
    }
}

