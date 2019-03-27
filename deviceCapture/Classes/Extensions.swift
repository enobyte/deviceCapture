//
//  Extension.swift
//  deviceCapture
//
//  Created by OCIN on 27/3/19.
//


import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork
import AVFoundation
import CoreLocation
import CoreBluetooth
import CoreTelephony
import Reachability
import FGRoute
import Contacts
import CoreNFC

extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}

extension AVAudioSession {
    
    static var isHeadphonesConnected: Bool {
        return sharedInstance().isHeadphonesConnected
    }
    
    var isHeadphonesConnected: Bool {
        return !currentRoute.outputs.filter { $0.isHeadphones }.isEmpty
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var displayName: String? {
        return infoDictionary?["CFBundleName"] as? String
    }
}

extension AVAudioSessionPortDescription {
    var isHeadphones: Bool {
        return portType == AVAudioSession.Port.headphones
    }
}

func fetchSSIDInfo() ->  String {
    var currentSSID = ""
    if let interfaces:CFArray = CNCopySupportedInterfaces() {
        for i in 0..<CFArrayGetCount(interfaces){
            let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
            let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
            let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
            if unsafeInterfaceData != nil {
                let interfaceData = unsafeInterfaceData! as Dictionary
                for dictData in interfaceData {
                    if dictData.key as! String == "SSID" {
                        currentSSID = dictData.value as! String
                    }
                }
            }
        }
    }
    return currentSSID
}

extension UILabel {
    func defaultLabel() -> UILabel {
        self.font = UIFont.systemFont(ofSize: 12)
        return self
    }
}


extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    var memoryUse: Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(taskInfo.resident_size / 1048576)
        }
        else {
            return 0
        }
    }
    
    var totalMemory: Double {
        return Double(ProcessInfo.processInfo.physicalMemory / 1073741824)
    }
    
    
    var cpuInfo: host_cpu_load_info? {
        let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride/MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        var cpuLoadInfo = host_cpu_load_info()
        
        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        if result != KERN_SUCCESS{
            return nil
        }
        return cpuLoadInfo
    }
    
    var cpuUsage:  Double {
        var totalUsageOfCPU: Double = 0.0
        var threadsList = UnsafeMutablePointer(mutating: [thread_act_t]())
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadsCount)
            }
        }
        
        if threadsResult == KERN_SUCCESS {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                    }
                }
                
                guard infoResult == KERN_SUCCESS else {
                    break
                }
                
                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0))
                }
            }
        }
        
        vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        return totalUsageOfCPU
    }
    
    var isSimulator: String {
        if (ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] != nil) {
            return "Yes"
        }else {
            return "No"
        }
    }
    
    var totalDiskSpace:String {
        get {
            return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
        }
    }
    
    var freeDiskSpace:String {
        get {
            return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
        }
    }
    
    var hasJailbreak: String {
        #if arch(i386) || arch(x86_64)
        return "No"
        #else
        let fileManager = FileManager.default
        if(fileManager.fileExists(atPath: "/bin/bash") ||
            fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
            fileManager.fileExists(atPath: "/etc/apt")) ||
            fileManager.fileExists(atPath: "/private/var/lib/apt/") ||
            fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
            fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") {
            return "Yes"
        } else {
            return "No"
        }
        #endif
    }
    
    var resolution: String{
        let nWidth  = UIScreen.main.nativeBounds.width
        let nHeight = UIScreen.main.nativeBounds.height
        return "\(nWidth) x \(nHeight) pixel"
    }
    
    var batreLvl: String{
        UIDevice.current.isBatteryMonitoringEnabled = true
        return String(self.batteryLevel * 100) + " %"
    }
    
    var isCharging: String{
        UIDevice.current.isBatteryMonitoringEnabled = true
        var value: String
        
        
        if (UIDevice.current.batteryState != .unplugged) {
            value = "Yes"
        }else {
            value = "No"
        }
        return value
    }
    
    var isFullCharging: String{
        UIDevice.current.isBatteryMonitoringEnabled = true
        var value: String
        if (UIDevice.current.batteryState == .full) {
            value = "Yes"
        }else {
            value = "No"
        }
        return value
    }
    
    var gpsComp: String{
        var gps: String
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                gps = "No"
            case .authorizedAlways, .authorizedWhenInUse:
                gps = "Yes"
            }
        } else {
            gps = "No"
        }
        return gps
    }
    
    func bluetooth(central: CBCentralManager) -> String {
        var bluetooth: String
        switch central.state {
        case .poweredOn:
            bluetooth = "Yes"
            print("Bluetooth is On.")
            break
        case .poweredOff:
            bluetooth = "No"
            print("Bluetooth is Off.")
            break
        case .resetting:
            bluetooth = "No"
            break
        case .unauthorized:
            bluetooth = "No"
            break
        case .unsupported:
            bluetooth = "No"
            break
        case .unknown:
            bluetooth = "No"
            break
        default:
            bluetooth = "No"
            break
            
        }
        return bluetooth
    }
    
    var carrierName: String {
        return CTCarrier().carrierName ?? "Unknown"
    }
    
    var carrierCountry: String {
        return Locale.current.regionCode ?? "Unknown"
    }
    
    var isoCountry: String {
        return CTCarrier().isoCountryCode ?? "Unknown"
    }
    
    var carrierMobileCode: String {
        return CTCarrier().mobileCountryCode ?? "Unknown"
    }
    
    var carrierMobileNetwork: String {
        return CTCarrier().mobileNetworkCode ?? "Unknown"
    }
    
    var allowVoip: Bool {
        return CTCarrier().allowsVOIP
    }
    
    var timeZone: String {
        return TimeZone.current.identifier
    }
    
    var language: String {
        return Locale.current.languageCode ?? "Unknown"
    }
    
    var country: String {
        return Locale.current.regionCode ?? "Unknown"
    }
    
    static var systemDeviceType: String = {
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
    
    func getAddresses() -> [NetInfo] {
        var addresses = [NetInfo]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            var ptr = ifaddr;
            while ptr != nil {
                
                let flags = Int32((ptr?.pointee.ifa_flags)!)
                var addr = ptr?.pointee.ifa_addr.pointee
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr?.sa_family == UInt8(AF_INET) || addr?.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
                                        nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String.init(validatingUTF8:hostname) {
                                
                                var net = ptr?.pointee.ifa_netmask.pointee
                                var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                                getnameinfo(&net!, socklen_t((net?.sa_len)!), &netmaskName, socklen_t(netmaskName.count),
                                            nil, socklen_t(0), NI_NUMERICHOST)// == 0
                                if let netmask = String.init(validatingUTF8:netmaskName) {
                                    addresses.append(NetInfo(ip: address, netmask: netmask))
                                }
                            }
                        }
                    }
                }
                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses
    }
    
    var cellOrWifi: String {
        let reachability = Reachability()!
        if reachability.connection == .wifi {
            return "Wifi"
        }else if reachability.connection == .cellular {
            return "Cell"
        }else {
            return "Unknown"
        }
    }
    
    var phoneComp: String {
        if CTCarrier().mobileNetworkCode != nil {
            return "Yes"
        }else {
            return "No"
        }
    }
    
    var dataComp: String {
        if isConnectedToNetwork() {
            return "Yes"
        }else {
            return "No"
        }
    }
    
    var isNFCAvailable: Bool {
        if NSClassFromString("NFCNDEFReaderSession") == nil { return false }
        if #available(iOS 11.0, *) {
            return NFCNDEFReaderSession.readingAvailable
        } else {
            return false
        }
    }
    
    
    var routerIP: String {
        return FGRoute.getGatewayIP()
    }
    
    var wifiMacAddr: String {
        return FGRoute.getBSSID() ?? "Unknown"
    }
    
    func isDebuggerAttached() -> String {
        if getppid() != 1 {
            return "Yes"
        }else{
            return "No"
        }
    }
    
    var getContact: String{
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        
        if results.count > 0 {
            return "Yes"
        }else {
            return "No"
        }
    }
    
    var checkAppInstall: String {
        
        let appName = "DeviceInfo"
        let appScheme = "\(appName)://DeviceInfo"
        let appUrl = URL(string: appScheme)
        
        if UIApplication.shared.canOpenURL(appUrl! as URL)
        {
            return "Installed"
            
        } else {
            return "Uninstalled"
        }
    }
    
    
}


var totalDiskSpaceInBytes:Int64 {
    guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
        let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
    return space
}

var freeDiskSpaceInBytes:Int64 {
    if #available(iOS 11.0, *) {
        if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
            return space ?? 0
        } else {
            return 0
        }
    } else {
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
            return freeSpace
        } else {
            return 0
        }
    }
}

func MBFormatter(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = ByteCountFormatter.Units.useMB
    formatter.countStyle = ByteCountFormatter.CountStyle.decimal
    formatter.includesUnit = false
    return formatter.string(fromByteCount: bytes) as String
}

struct NetInfo {
    let ip: String
    let netmask: String
}

func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
        return false
    }
    // Working for Cellular and WIFI
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    let ret = (isReachable && !needsConnection)
    
    return ret
}



