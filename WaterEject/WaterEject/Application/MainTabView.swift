//
//  MainTabView.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            WaterEjectView()
                .tabItem {
                    Label("Cleaner", systemImage: "drop.fill")
                }
                .symbolEffect(.bounce, options: .repeat(1), value: true)
            
            ToneGeneratorView()
                .tabItem {
                    Label("Tone", systemImage: "waveform")
                }
                .symbolEffect(.bounce, options: .repeat(1), value: true)
            
            // Add dB Meter tab
            DBMeterView()
                .tabItem {
                    Label("dB Meter", systemImage: "speaker.wave.2")
                }
                .symbolEffect(.bounce, options: .repeat(1), value: true)
        }
    }
}

#Preview {
    MainTabView()
}
