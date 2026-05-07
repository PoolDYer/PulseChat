//
//  PrimaryButton.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import SwiftUI

struct PrimaryButton: View {

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primary)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}
