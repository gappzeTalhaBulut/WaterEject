//
//  SettingsView.swift
//  WaterEject
//
//  Created by Talha on 14.03.2025.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        // Premium action
                    }) {
                        HStack {
                            Label("Get Premium", systemImage: "crown.fill")
                                .foregroundColor(Color(uiColor: .systemYellow))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(uiColor: .systemGray4))
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        // Share action
                    }) {
                        Label("Share App", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        // Rate action
                    }) {
                        Label("Rate Us", systemImage: "star.fill")
                    }
                }
                
                Section {
                    Button(action: {
                        // Privacy action
                    }) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    Button(action: {
                        // Terms action
                    }) {
                        Label("Terms of Use", systemImage: "doc.text.fill")
                    }
                }
                
                Section {
                    Button(action: {
                        // Restore action
                    }) {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
