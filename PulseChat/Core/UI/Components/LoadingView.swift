//
//  LoadingView.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
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
