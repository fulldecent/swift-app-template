import SwiftUI

#if os(macOS)
  import AppKit
#endif

func screenshotValue() -> Int {
  ProcessInfo.processInfo.arguments.contains("-screenshot") ? 1 : 0
}

#if os(macOS)
  enum MacScreenshot {
    static let width: CGFloat = 1440
    static let height: CGFloat = 900

    /// Writes a 1440×900 PNG and exits when launched with `-screenshot-file`.
    /// A GitHub-hosted runner cannot list another app's windows without Screen Recording permission.
    static func exportIfRequested(value: Int) {
      let arguments = ProcessInfo.processInfo.arguments
      guard let index = arguments.firstIndex(of: "-screenshot-file"),
        arguments.indices.contains(index + 1)
      else { return }

      let renderer = ImageRenderer(
        content: CounterCanvas(value: value)
          .frame(width: width, height: height)
      )
      renderer.scale = 1

      guard let image = renderer.nsImage,
        let tiff = image.tiffRepresentation,
        let rep = NSBitmapImageRep(data: tiff),
        rep.pixelsWide == Int(width),
        rep.pixelsHigh == Int(height),
        let png = rep.representation(using: .png, properties: [:])
      else {
        fputs("could not render a \(Int(width))×\(Int(height)) Mac screenshot\n", stderr)
        exit(1)
      }

      let url = URL(fileURLWithPath: arguments[index + 1])
      do {
        try FileManager.default.createDirectory(
          at: url.deletingLastPathComponent(),
          withIntermediateDirectories: true
        )
        try png.write(to: url)
      } catch {
        fputs("could not write Mac screenshot: \(error)\n", stderr)
        exit(1)
      }
      exit(0)
    }
  }
#endif

struct CounterCanvas: View {
  let value: Int

  var body: some View {
    Text("\(value)")
      .font(.system(size: 240, weight: .bold))
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black)
  }
}

struct ContentView: View {
  @State private var model = CounterModel()

  var body: some View {
    CounterCanvas(value: model.value)
      .onTapGesture {
        model.increment()
      }
      .onAppear {
        if ProcessInfo.processInfo.arguments.contains("-screenshot") {
          model.increment()
        }
      }
  }
}

#Preview {
  ContentView()
}
