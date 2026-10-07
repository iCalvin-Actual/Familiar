import Familiar
import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .analytics(ConsoleAnalytics())
        }
    }
}
