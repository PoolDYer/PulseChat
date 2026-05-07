//
//  ErrorView.swift
//  PulseChat
//

import SwiftUI

struct ErrorView: View {

    let message: String

    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .padding()
            .accessibilityLabel(AppStrings.errorTitle)
            .accessibilityValue(message)
    }
}
