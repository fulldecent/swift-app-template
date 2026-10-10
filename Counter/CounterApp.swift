import SwiftUI

@main
struct CounterApp: App {
  init() {
    #if os(macOS)
      MacScreenshot.exportIfRequested(value: screenshotValue())
    #endif
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
