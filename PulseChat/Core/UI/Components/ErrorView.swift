//
//  ErrorView.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
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
