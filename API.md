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
Data Component: \(UIDevice.current.dataComp
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







