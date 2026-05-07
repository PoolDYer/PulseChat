//
//  EmptyStateView.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
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

