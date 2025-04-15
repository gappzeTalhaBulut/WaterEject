//
//  MainTabView.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WaterEjectView()
                .tabItem {
                    Label("Cleaner", systemImage: "drop.fill")
                }
                .tag(0)
                .symbolEffect(.bounce, options: .repeat(1), value: true)
            
            ToneGeneratorView()
                .tabItem {
                    Label("Tone", systemImage: "waveform")
                }
                .tag(1)
                .symbolEffect(.bounce, options: .repeat(1), value: true)
            
            DBMeterView()
                .tabItem {
                    Label("dB Meter", systemImage: "mic.and.signal.meter.fill")
                }
                .tag(2)
                .symbolEffect(.bounce, options: .repeat(1), value: true)
            
            StereoView()
                .tabItem {
                    Label("Stereo", systemImage: "music.quarternote.3")
                }
                .tag(3)
                .symbolEffect(.bounce, options: .repeat(1), value: true)
        }
        .adaptyPaywall()
    }
}

#Preview {
    MainTabView()
}
