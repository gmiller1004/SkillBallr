import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
            .environmentObject(AppState())
            .environmentObject(AuthenticationManager())
            .environmentObject(SubscriptionManager())
    }
}

#Preview {
    ContentView()
}
