import Familiar
import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .analytics(ConsoleAnalytics())
                // Remote artwork comes from a table, not the network.
                .imageLoader(MockImageLoader.catalog)
        }
    }
}
