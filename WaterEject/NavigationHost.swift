//
//  NavigationHost.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import SwiftUI

public enum NavigationState {
    case splash
    case home
    case intro
    case paywall
    case settings
}

public class NavigationManager: ObservableObject {
    public static let shared = NavigationManager()
    
    @Published public var currentState: NavigationState = .splash
    
    private init() {}
    
    public func navigate(to state: NavigationState) {
        DispatchQueue.main.async {
            withAnimation {
                self.currentState = state
            }
        }
    }
}
