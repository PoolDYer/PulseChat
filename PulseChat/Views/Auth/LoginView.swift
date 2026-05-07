//
//  LoginView.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import SwiftUI

struct LoginView: View {

    @StateObject var viewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isRegister = false

    var body: some View {
        VStack {
            LanguagePickerView()
            ThemePickerView()

            Spacer(minLength: 0)

            VStack(spacing: 20) {

                Text(AppStrings.appName)
                    .font(.largeTitle)
                    .bold()

                TextField(AppStrings.emailPlaceholder, text: $email)
                    .textFieldStyle(.roundedBorder)

                SecureField(AppStrings.passwordPlaceholder, text: $password)
                    .textFieldStyle(.roundedBorder)

                if viewModel.isLoading {
                    ProgressView()
                        .accessibilityLabel(AppStrings.loading)
                }

                Button {
                    Task {
                        if isRegister {
                            await viewModel.register(email: email, password: password)
                        } else {
                            await viewModel.login(email: email, password: password)
                        }
                    }
                } label: {
                    ZStack {
                        if isRegister {
                            Text(AppStrings.register)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            Text(AppStrings.login)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .buttonStyle(
                    SoftButtonStyle(
                        background: AppColors.primary.opacity(0.15),
                        pressedBackground: AppColors.primary.opacity(0.25),
                        foreground: AppColors.primary
                    )
                )

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRegister.toggle()
                    }
                } label: {
                    Text(isRegister ? AppStrings.alreadyHaveAccount : AppStrings.createAccount)
                }
                .buttonStyle(
                    SoftButtonStyle(
                        background: Color.gray.opacity(0.12),
                        pressedBackground: Color.gray.opacity(0.22),
                        foreground: .primary,
                        borderColor: Color.gray.opacity(0.25)
                    )
                )

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isRegister)

            Spacer(minLength: 0)
        }
        .padding()
    }
}

private struct SoftButtonStyle: ButtonStyle {
    let background: Color
    let pressedBackground: Color
    let foreground: Color
    var borderColor: Color? = nil
    var cornerRadius: CGFloat = 12
    var borderWidth: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? pressedBackground : background)
            .foregroundColor(foreground)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor ?? .clear, lineWidth: borderWidth)
            )
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

