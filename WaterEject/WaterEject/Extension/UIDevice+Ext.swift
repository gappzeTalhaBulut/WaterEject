//
//  UIDevice+Ext.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation
import UIKit

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
enum NetworkType: String {
    case wifi = "en0"
    case cellular = "pdp_ip0"
}
enum Devices {
    case small
    case mid
    case large
    case ipad
    case ipadXl
}

extension UIDevice {
    var screenSize: Devices {
        let screenSize = UIScreen.main.bounds.size
        let width = Int(screenSize.width)
        let height = Int(screenSize.height)
        let screenHeight = max(width, height)
        
        switch screenHeight {
            case 568...667:
                return .small // iPhone 6, 6s, 7, 8, SE (2nd generation)
            case 736:
                return .mid // iPhone 6 Plus, 6s Plus, 7 Plus, 8 Plus
            case 812:
                return .mid // iPhone X, XS, 11 Pro, 12 mini
                /// iphone 11
            case 896:
                return .mid // iPhone XR, 11, 12, 13 mini
            case 926:
                return .mid // iPhone 13
                /// Büyük ekran pro max
            case 844:
                return .large // iPhone 12 Pro Max, 13 Pro Max
            case 1024:
                return .ipad // iPad Mini
            case 1112:
                return .ipad // iPad Pro (10.5-inch)
            case 1194:
                return .ipadXl // iPad Pro (11-inch) (1st, 2nd, 3rd generation)
            case 1366:
                return .ipad // iPad Pro (12.9-inch) (1st, 2nd, 3rd, 4th generation)
            default:
                return .mid
        }
    }
    
    func getIpAddress(for network: NetworkType) -> String? {
        var address: String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
}
public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String {
#if os(iOS)
            switch identifier {
                case "iPod5,1":                                 return "iPod Touch 5"
                case "iPod7,1":                                 return "iPod Touch 6"
                case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
                case "iPhone4,1":                               return "iPhone 4s"
                case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
                case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
                case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
                case "iPhone7,2":                               return "iPhone 6"
                case "iPhone7,1":                               return "iPhone 6 Plus"
                case "iPhone8,1":                               return "iPhone 6s"
                case "iPhone8,2":                               return "iPhone 6s Plus"
                case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
                case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
                case "iPhone8,4":                               return "iPhone SE"
                case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
                case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
                case "iPhone10,3", "iPhone10,6":                return "iPhone X"
                case "iPhone11,2":                              return "iPhone XS"
                case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
                case "iPhone11,8":                              return "iPhone XR"
                case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
                case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
                case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
                case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
                case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
                case "iPad6,11", "iPad6,12":                    return "iPad 5"
                case "iPad7,5", "iPad7,6":                      return "iPad 6"
                case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
                case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
                case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
                case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
                case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
                case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
                case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
                case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
                case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
                case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
                case "AppleTV5,3":                              return "Apple TV"
                case "AppleTV6,2":                              return "Apple TV 4K"
                case "AudioAccessory1,1":                       return "HomePod"
                case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
                default:                                        return identifier
            }
#elseif os(tvOS)
            switch identifier {
                case "AppleTV5,3": return "Apple TV 4"
                case "AppleTV6,2": return "Apple TV 4K"
                case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
                default: return identifier
            }
#endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}
