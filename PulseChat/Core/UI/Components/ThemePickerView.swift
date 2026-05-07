import SwiftUI

struct ThemePickerView: View {
    @AppStorage("pulsechat.theme") private var themeMode = ThemeMode.system.rawValue

    var body: some View {
        Picker(AppStrings.themeLabel, selection: $themeMode) {
            ForEach(ThemeMode.allCases) { mode in
                Text(mode.title)
                    .tag(mode.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}
