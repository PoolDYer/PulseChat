//
//  LoadingView.swift
//  PulseChat
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.3)
                .accessibilityLabel(AppStrings.loading)
        }
        .padding()
    }
}
