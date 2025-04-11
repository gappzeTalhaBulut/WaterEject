//
//  RemoteConfigProtocol.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation
protocol RemoteConfigProtocol  {
    var didGetConfig: (() -> ())? { get set }
    func string(for key: ConfigKey) -> String
    func double(for key: ConfigKey) -> Double
    func int(for key: ConfigKey) -> Int
    var response: AppOpenResponse? { get set }
    var didFetchConfig: ((_ response: AppOpenResponse?) -> Void)? { get set }
    func getRemoteConfig(completion: @escaping (Result<AppOpenResponse, Error>) -> Void)
}
