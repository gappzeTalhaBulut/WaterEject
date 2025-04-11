//
//  ConfigKey.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation

protocol ConfigKey {
    var name: String { get }
    var offline: Any { get }
}
