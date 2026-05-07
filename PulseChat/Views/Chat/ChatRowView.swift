//
//  ChatRowView.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import SwiftUI

struct ChatRowView: View {

    let chat: Chat
    let currentUserId: String

    var body: some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(chatDisplayName)
                .font(.headline)

            Text(chat.lastMessage)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    // Mostrar SOLO otros usuarios
    private var chatDisplayName: String {

        let others = chat.participants.filter {
            $0.id != currentUserId
        }

        if others.isEmpty {
            return AppStrings.you
        }

        return others
            .map { $0.email }
            .joined(separator: ", ")
    }
}
