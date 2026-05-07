//
//  Strings.swift
//  PulseChat
//

import Foundation

enum AppStrings {
    static var appName: String { Localization.string("app_name") }
    static var login: String { Localization.string("login") }
    static var register: String { Localization.string("register") }
    static var emailPlaceholder: String { Localization.string("email_placeholder") }
    static var passwordPlaceholder: String { Localization.string("password_placeholder") }
    static var alreadyHaveAccount: String { Localization.string("already_have_account") }
    static var createAccount: String { Localization.string("create_account") }

    static var chats: String { Localization.string("chats_title") }
    static var send: String { Localization.string("send_button") }
    static var cancel: String { Localization.string("cancel_button") }
    static var logout: String { Localization.string("logout_button") }
    static var searchPlaceholder: String { Localization.string("search_placeholder") }
    static var search: String { Localization.string("search_button") }
    static var searchUsersTitle: String { Localization.string("search_users_title") }
    static var emptyChats: String { Localization.string("empty_chats") }
    static var emptyMessages: String { Localization.string("empty_messages") }
    static var offlineBanner: String { Localization.string("offline_banner") }
    static var you: String { Localization.string("you_label") }

    static var gallery: String { Localization.string("gallery_option") }
    static var camera: String { Localization.string("camera_option") }
    static var messagePlaceholder: String { Localization.string("message_placeholder") }
    static var edit: String { Localization.string("edit_action") }
    static var delete: String { Localization.string("delete_action") }

    static var loading: String { Localization.string("loading") }
    static var errorTitle: String { Localization.string("error_title") }

    static var themeLabel: String { Localization.string("theme_label") }
    static var themeSystem: String { Localization.string("theme_system") }
    static var themeLight: String { Localization.string("theme_light") }
    static var themeDark: String { Localization.string("theme_dark") }

    static var languageLabel: String { Localization.string("language_label") }
    static var languageSystem: String { Localization.string("language_system") }
    static var languageEnglish: String { Localization.string("language_english") }
    static var languageSpanish: String { Localization.string("language_spanish") }
    static var languageMenuHint: String { Localization.string("language_menu_hint") }

    static var attachMenu: String { Localization.string("attach_menu") }
    static var attachMenuHint: String { Localization.string("attach_menu_hint") }
    static var removeAttachment: String { Localization.string("remove_attachment") }
    static var imageAttachment: String { Localization.string("image_attachment") }
    static var searchUsersHint: String { Localization.string("search_users_hint") }
    static var sendHint: String { Localization.string("send_hint") }
    static var cancelEditHint: String { Localization.string("cancel_edit_hint") }

    static var errorAuthInvalidEmail: String { Localization.string("error_auth_invalid_email") }
    static var errorAuthWrongPassword: String { Localization.string("error_auth_wrong_password") }
    static var errorAuthUserNotFound: String { Localization.string("error_auth_user_not_found") }
    static var errorAuthEmailInUse: String { Localization.string("error_auth_email_in_use") }
    static var errorAuthWeakPassword: String { Localization.string("error_auth_weak_password") }
    static var errorAuthNetwork: String { Localization.string("error_auth_network") }
    static var errorAuthDefault: String { Localization.string("error_auth_default") }
    static var errorRegisterExisting: String { Localization.string("error_register_existing") }

    static var errorSendMessage: String { Localization.string("error_send_message") }
    static var errorDeleteMessage: String { Localization.string("error_delete_message") }
    static var errorEditMessage: String { Localization.string("error_edit_message") }
    static var errorMessageRequired: String { Localization.string("error_message_required") }

    static var errorApiInvalidResponse: String { Localization.string("error_api_invalid_response") }
    static var imageMessageFallback: String { Localization.string("image_message_fallback") }

    static func httpError(_ code: Int) -> String {
        Localization.format("error_http_format", code)
    }
}
