import SwiftUI

struct LanguagePickerView: View {
    @AppStorage("pulsechat.language") private var languageCode = AppLanguage.system.rawValue

    var body: some View {
        Picker(AppStrings.languageLabel, selection: $languageCode) {
            ForEach(AppLanguage.allCases) { language in
                Text(language.title)
                    .tag(language.rawValue)
            }
        }
        .pickerStyle(.menu)
        .padding(.horizontal)
        .padding(.bottom, 4)
        .accessibilityLabel(AppStrings.languageLabel)
        .accessibilityHint(AppStrings.languageMenuHint)
    }
}
