import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @EnvironmentObject var store: FobStore
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                FobTheme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundColor(FobTheme.accent)
                    Text("Unlock Key Fob Battery Tracker Pro")
                        .font(FobTheme.titleFont)
                        .foregroundColor(FobTheme.textPrimary)
                    Text("Multi-fob/vehicle tracking with battery type notes")
                        .font(FobTheme.bodyFont)
                        .foregroundColor(FobTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        Task { await purchase() }
                    } label: {
                        Text(isPurchasing ? "Processing..." : "Subscribe $1.99/month")
                            .font(FobTheme.bodyFont.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(FobTheme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(isPurchasing)
                    .accessibilityIdentifier("subscribeButton")
                    .padding(.horizontal)
                    if let errorMessage {
                        Text(errorMessage).foregroundColor(.red).font(.caption)
                    }
                    Button("Not now") { dismiss() }
                        .foregroundColor(FobTheme.textSecondary)
                        .accessibilityIdentifier("dismissPaywallButton")
                }
                .padding()
            }
        }
    }

    private func purchase() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await purchases.purchasePro()
            if purchases.isPro {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseManager())
        .environmentObject(FobStore())
}
