//
//  NavigationHost.swift
//  WaterEject
//
//  Created by Talha on 14.03.2025.
//

import Foundation
import SwiftUI

struct NavigationHost<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            Button(action: {
                                // Premium action
                            }) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(Color(uiColor: .systemYellow))
                            }
                            
                            Button(action: {
                                // Settings action
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(Color(uiColor: .label))
                            }
                        }
                    }
                }
        }
    }
}
