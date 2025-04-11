//
//  PaywallStartView.swift
//  WaterEject
//
//  Created by Talha on 10.04.2025.
//

import SwiftUI
import AdaptyUI

struct PaywallStartView: View {
    let action: AppPaywallAction
    let onDismiss: () -> Void
    private let paywallRepository = PaywallRepository.shared
    
    var body: some View {
        Color.clear
            .onAppear {
                Task {
                    await openPaywall()
                }
            }
            .adaptyPaywall()
    }
    
    private func openPaywall() async {
        await paywallRepository.openPaywallIfEnabled(
            action: action,
            isNotVisibleAction: onDismiss,
            onCloseAction: onDismiss,
            onPurchaseSuccess: onDismiss,
            onRestoreSuccess: onDismiss
        )
    }
}

#Preview {
    PaywallStartView(action: .onboarding, onDismiss: {})
}
