//
//  RemoteConfigManager.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation
import FirebaseRemoteConfig

final class RemoteConfigManager: RemoteConfigProtocol {
    
    var response: AppOpenResponse?
    static let shared = RemoteConfigManager()
    
    var didFetchConfig: ((AppOpenResponse?) -> Void)?
    var didGetConfig: (() -> ())?
    private let config: RemoteConfig
    
    private init(config: RemoteConfig = .remoteConfig()) {
        self.config = config
        configure()
        getRemoteKeys()
    }
    
    func getRemoteConfig(completion: @escaping (Result<AppOpenResponse, Error>) -> Void) {
        config.fetchAndActivate { [weak self] status, error in
            if let error = error {
                print("Error fetching and activating config: \(error.localizedDescription)")
                self?.handleFallbackData { result in
                    switch result {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else {
                switch status {
                case .successFetchedFromRemote, .successUsingPreFetchedData:
                    print("Config fetched and activated successfully.")
                    self?.processRemoteConfigData { result in
                        switch result {
                        case .success(let data):
                            completion(.success(data))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                default:
                    print("Config not fetched and activated successfully. Status: \(status.rawValue)")
                    self?.handleFallbackData { result in
                        switch result {
                        case .success(let data):
                            self?.didFetchConfig?(data) // pass the response in case of success
                            completion(.success(data))
                        case .failure(let error):
                            _ = NSError(domain: "CustomErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Config not fetched and activated successfully"])
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }


    
    func handleFallbackData(completion: @escaping (Result<AppOpenResponse, Error>) -> Void) {
        if let fallbackData = fallbackJsonString.data(using: .utf8) {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: fallbackData, options: [])
                if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                   let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                    print(prettyPrintedString)
                    let data: AppOpenResponse = try JSONDecoder().decode(AppOpenResponse.self, from: prettyPrintedData)
                    self.response = data
                    print(data)
                    completion(.success(data))
                }
            } catch {
                print("Error parsing fallback JSON: \(error)")
                completion(.failure(error))
            }
        }
    }

    func processRemoteConfigData(completion: @escaping (Result<AppOpenResponse, Error>) -> Void) {
        let jsonString = config.configValue(forKey: "appOpen").stringValue
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                   let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                    print(prettyPrintedString)
                    let data: AppOpenResponse = try JSONDecoder().decode(AppOpenResponse.self, from: prettyPrintedData)
                    self.response = data
                    print(data)
                    completion(.success(data))
                }
            } catch {
                print("Error parsing remote config JSON: \(error)")
                completion(.failure(error))
            }
        }
    }

    
    func string(for key: ConfigKey) -> String {
        return RemoteConfig.remoteConfig()[key.name].stringValue ?? ""
    }
    
    func double(for key: ConfigKey) -> Double {
        return config[key.name].numberValue.doubleValue
    }
    
    func int(for key: ConfigKey) -> Int {
        return Int(truncating: config[key.name].numberValue)
    }
    private let fallbackJsonString: String = """

{
  "status": "success",
  "version": "1",
  "isPremium": false,
  "paywallActions": {
    "favorite": {
      "show": true,
      "placementId": "favAction-allUsers"
    },
    "onboarding": {
      "show": true,
      "placementId": "onboardingAction-allUsers"
    },
    "scan": {
      "show": true,
      "placementId": "scanAction-allUsers"
    },
    "map": {
      "show": true,
      "placementId": "mapAction-allUsers"
    },
    "premium": {
      "show": true,
      "placementId": "premiumAction-allUsers"
    },
    "event": {
      "show": true,
      "placementId": "eventAction-allUsers"
    },
    "push": {
      "show": true,
      "placementId": "pushAction-allUsers"
    }
  }
}
"""
    
}

private extension RemoteConfigManager {
    func configure() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        config.configSettings = settings
    }
    
    func getRemoteKeys() {
        config.fetchAndActivate() { [weak self] (_, error) -> Void in
            if let error = error {
                print(error)
                self?.getOfflineKeys()
            }
            self?.didGetConfig?()
        }
    }
    
    func getOfflineKeys() {
        config.setDefaults(getDefaults() as? [String: NSObject])
    }
    
    func getDefaults() -> [String: Any] {
        return FireBaseRemoteConfigKey.allCases.reduce( [String: Any](), {current, key in
            var dictionary = current
            dictionary[key.rawValue] = key.offline
            return dictionary
        })
    }
    
}



private extension RemoteConfigManager {
    func logJSONResponse(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print(String(decoding: jsonData, as: UTF8.self))
        } else {
            print("json data malformed")
        }
    }
}
