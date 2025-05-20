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
            
            ToneGeneratorView()
                .tabItem {
                    Label("Tone", systemImage: "waveform")
                }
                .tag(1)
            
            DBMeterView()
                .tabItem {
                    Label("dB Meter", systemImage: "mic.and.signal.meter.fill")
                }
                .tag(2)
            
            StereoView()
                .tabItem {
                    Label("Stereo", systemImage: "music.quarternote.3")
                }
                .tag(3)
        }
        .tint(Color(uiColor: .primary))
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(.black, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .background(.black)
        .adaptyPaywall()
    }
}

#Preview {
    MainTabView()
}
