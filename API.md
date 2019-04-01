# API
The list of available methods for this plugin is described below.

## Disk Space
```
UIDevice.current.totalDiskSpace
```

## Free Disk Space
```
UIDevice.current.freeDiskSpace
```

## Screen Resolution
```
UIDevice.current.resolution
```

## Screen Brightness
```
UIScreen.main.brightness
```

## Device Brand Name
```
UIDevice.current.model
```

## Device Type
```
UIDevice.current.model
```

## Device Name
```
UIDevice.current.name
```

## Cpu Usage
```
UIDevice.current.cpuUsage
```

## Total Memory (GB)
```
UIDevice.current.totalMemory
```

## Memory Used (MB)
```
UIDevice.current.memoryUse
```

## Battery Level (%)
```
UIDevice.current.batreLvl
```

## is Charging
```
UIDevice.current.isCharging
```

## Fully Charging
```
UIDevice.current.isFullCharging
```

## Use Headphone (Boolean)
```
AVAudioSession.isHeadphonesConnected
```

## Unique Device Identifier
```
UIDevice.current.identifierForVendor!.uuidString
```

## Wifi Mac
```
UIDevice.current.wifiMacAddr
```
## Simulator 
```
UIDevice.current.isSimulator
```
## Wifi Component (Return String)

If != isEmpty => Wifi Component is Yes

```
fetchSSIDInfo().isEmpty
```

## Data Component

```
Data Component: UIDevice.current.dataComp
```

## GPS Component
```
UIDevice.current.gpsComp
```
## Phone Component
```
UIDevice.current.phoneComp
```

## Earphone Component (Boolean)
```
AVAudioSession.isHeadphonesConnected
```

## NFC Component (Boolean)

```
UIDevice.current.isNFCAvailable
```

For iPhone 7 and newer model you add NFC Requirement in Info.plist :
```
<key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>nfc</string>
    </array>
```

## Carrier Name

```
UIDevice.current.carrierName
```

## Carrier Allows VOIP
```
UIDevice.current.allowVoip
```

## Carrier Country
```
UIDevice.current.carrierCountry
```

## Carrier ISO Country Code
```
UIDevice.current.isoCountry
```

## Carrier Mobile Country Code
```
UIDevice.current.carrierMobileCode
```

## Carrier Mobile Network Code
```
UIDevice.current.carrierMobileNetwork
```

## System Device Type
```
String(describing: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!)
```

## System Version
```
UIDevice.current.systemVersion
```

## Language
```
UIDevice.current.language
```

## Country
```
UIDevice.current.country
```

## Time Zone
```
UIDevice.current.timeZone
```

## JailBroken
```
UIDevice.current.hasJailbreak
```

## IP Address
```
UIDevice.current.getAddresses().last!.ip
```

## Netmask Address
```
UIDevice.current.getAddresses().last!.netmask
```

## Cellular Or Wifi
```
UIDevice.current.cellOrWifi
```

## Router Address
```
UIDevice.current.routerIP
```

## Contact
```
UIDevice.current.getContact
```
Don't forget add Contact Requirement in Info.plist

```
<key>NSContactsUsageDescription</key>
	<string>Apps Will Capture your Contact (Replace me)</string>
```

## Location

Example :

```
class MainViewController: UIViewController, CLLocationManagerDelegate{
    var locationManager:CLLocationManager!
}

override func viewDidLoad() {
        super.viewDidLoad()
        determineMyCurrentLocation()
}

func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        userLocation.coordinate.latitude // Get Latitude
	userLocation.coordinate.longitude // Get Longitude
        userLocation.altitude // Get Altitude
	userLocation.speed // Get Speed
        
  }

func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {}
```

## Bluetooth Component 

```
class MainViewController: UIViewController{
 var managerBluetooth:CBCentralManager!
}

override func viewDidLoad() {
        super.viewDidLoad()
        managerBluetooth          = CBCentralManager()
        managerBluetooth.delegate = self as? CBCentralManagerDelegate
}

Use this : UIDevice.current.bluetooth(central: managerBluetooth)
```





