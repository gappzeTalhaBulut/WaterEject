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
            
            ToneGeneratorView()
                .tabItem {
                    Label("Tone", systemImage: "waveform")
                }
            
            // Add dB Meter tab
            DBMeterView()
                .tabItem {
                    Label("dB Meter", systemImage: "speaker.wave.2")
                }
        }
    }
}

#Preview {
    MainTabView()
}
