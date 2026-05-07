import SwiftUI
import UIKit

struct ChatDetailView: View {

    @StateObject var viewModel: ChatDetailViewModel
    let chatTitle: String
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack(spacing: 0) {

            if !networkMonitor.isConnected {
                offlineBanner
            }

            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.messages.isEmpty {
                EmptyStateView(message: AppStrings.emptyMessages)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            messageRow(message)
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                ErrorView(message: error)
            }

            Divider()

            HStack {
                HStack(spacing: 8) {
                    Menu {
                        Button {
                            imageSource = .photoLibrary
                            showImagePicker = true
                        } label: {
                            Label(AppStrings.gallery, systemImage: "photo.on.rectangle")
                        }

                        Button {
                            imageSource = .camera
                            showImagePicker = true
                        } label: {
                            Label(AppStrings.camera, systemImage: "camera")
                        }
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(AppColors.primary)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 28, height: 28)
                            .background(AppColors.primary.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(AppStrings.attachMenu)
                    .accessibilityHint(AppStrings.attachMenuHint)

                    TextField(AppStrings.messagePlaceholder, text: $viewModel.messageText)
                        .textFieldStyle(.plain)

                    if let image = viewModel.attachedImage {
                        HStack(spacing: 6) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 28, height: 28)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .accessibilityLabel(AppStrings.imageAttachment)

                            Button {
                                viewModel.removeAttachment()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityLabel(AppStrings.removeAttachment)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )

                Button(AppStrings.send) {
                    Task {
                        await viewModel.sendMessage()
                    }
                }
                .accessibilityHint(AppStrings.sendHint)
                if viewModel.editingMessageId != nil {
                    Button(AppStrings.cancel) {
                        viewModel.cancelEditing()
                    }
                    .foregroundColor(.secondary)
                    .accessibilityHint(AppStrings.cancelEditHint)
                }
            }
            .padding()
        }
        .navigationTitle(chatTitle)
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(sourceType: imageSource) { image in
                viewModel.attachImage(image)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadMessages()
            }
        }
    }
}

private extension ChatDetailView {

    func messageRow(_ message: Message) -> some View {

        let isMe = message.senderId == viewModel.currentUserId
        let isEditing = viewModel.editingMessageId == message.id

        return HStack {
            if isMe {
                Spacer()
                messageContent(message, isMe: true)
            } else {
                messageContent(message, isMe: false)
                Spacer()
            }
        }
        .padding(.horizontal)
        .contextMenu {
            if isMe {
                Button(AppStrings.edit) {
                    viewModel.startEditing(message)
                }

                Button(AppStrings.delete, role: .destructive) {
                    Task {
                        await viewModel.deleteMessage(message)
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditing ? Color.orange.opacity(0.6) : .clear, lineWidth: 1)
        )
    }

    @ViewBuilder
    func messageContent(_ message: Message, isMe: Bool) -> some View {
        let background = isMe ? Color.blue : Color.gray.opacity(0.2)
        let foreground = isMe ? Color.white : Color.primary

        VStack(alignment: .leading, spacing: 6) {
            if let data = message.imageData,
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 220, maxHeight: 160)
                    .clipped()
                    .cornerRadius(8)
                    .accessibilityLabel(AppStrings.imageAttachment)
            }

            if !message.text.isEmpty {
                Text(message.text)
                    .foregroundColor(foreground)
            }
        }
        .padding(10)
        .background(background)
        .cornerRadius(10)
    }

    var offlineBanner: some View {
        Text(AppStrings.offlineBanner)
            .font(.footnote)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color.yellow.opacity(0.2))
            .foregroundColor(.orange)
    }
}
