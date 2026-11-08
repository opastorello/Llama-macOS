import AppKit

/// A display language the app ships a localization for. The list comes from
/// the bundle, so adding a language to `Localizable.xcstrings` is all it takes
/// for it to appear in Settings.
///
/// The choice is stored in the app's own `AppleLanguages` default, which is
/// what the system reads at launch to pick a localization, so a change only
/// takes effect after a restart.
struct AppLanguage: Hashable, Identifiable {
  let code: String

  var id: String { code }

  /// Named in its own language, so someone who can't read the current one can
  /// still find theirs.
  var displayName: String {
    let locale = Locale(identifier: code)
    return (locale.localizedString(forIdentifier: code) ?? code).localizedCapitalized
  }

  static let all: [AppLanguage] = {
    var codes = Set(Bundle.main.localizations)
    if let development = Bundle.main.developmentLocalization { codes.insert(development) }
    codes.remove("Base")
    return codes.map(AppLanguage.init).sorted { $0.displayName < $1.displayName }
  }()

  /// The language this launch resolved to: the saved choice, else the
  /// system's closest match, else the development language.
  static var current: AppLanguage {
    get {
      let resolved = Bundle.main.preferredLocalizations.first
      return all.first { $0.code == resolved } ?? AppLanguage(code: "en")
    }
    set {
      UserDefaults.standard.set([newValue.code], forKey: "AppleLanguages")
    }
  }

  /// Asks whether to restart now, since the new language applies on launch.
  @MainActor
  static func offerRestart() {
    let alert = NSAlert()
    alert.messageText = String(localized: "Restart Llama to change the language")
    alert.informativeText = String(
      localized: "The server stops while Llama restarts, and the loaded model is unloaded.")
    alert.addButton(withTitle: String(localized: "Restart Now"))
    alert.addButton(withTitle: String(localized: "Later"))
    guard alert.runModal() == .alertFirstButtonReturn else { return }

    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/sh")
    task.arguments = ["-c", "sleep 1; /usr/bin/open -n \"$0\"", Bundle.main.bundlePath]
    try? task.run()
    NSApp.terminate(nil)
  }
}
