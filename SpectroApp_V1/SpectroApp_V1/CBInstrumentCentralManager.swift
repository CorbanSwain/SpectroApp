//________________________________________________________//
//                                                        //
//  CBInstrumentCentralManager.swift                      //
//  SpectroApp_V1                                         //
//                                                        //
//  Creator: Corban Swain                                 //
//  DATE: 3/16/17.                                        //
//  Copyright © 2017 CorbanSwain. All rights reserved.    //
//                                                        //
//________________________________________________________//




// ----------------------------------------------------------------------
// MARK: - Import Packages
// ----------------------------------------------------------------------
import UIKit
import CoreBluetooth



// ----------------------------------------------------------------------
// MARK: - UUIDs
// ----------------------------------------------------------------------

/// A 128-bit universially unnique identifier (UUID) for the UART service, for more information about the UART service see [adafruit.learn.com](https://learn.adafruit.com/introducing-adafruit-ble-bluetooth-low-energy-friend/uart-service)
fileprivate let uartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

/// The UUID for the transmission charachteristic of the [UART service](https://learn.adafruit.com/introducing-adafruit-ble-bluetooth-low-energy-friend/uart-service)
fileprivate let uartTXCharID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")


/// The UUID for the recieving charachteristic of the [UART service](https://learn.adafruit.com/introducing-adafruit-ble-bluetooth-low-energy-friend/uart-service), data from the instrment is sent through this charachteristic
fileprivate let uartRXCharID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")


/// The UUID for the LEGO Spectrophotometer peripheral: the device used for app testing in Spring 2017. The arduino in this device is an [Adafruit Feather M0 Bluefruit LE](https://learn.adafruit.com/adafruit-feather-m0-bluefruit-le/overview).
fileprivate let legoSpecID = UUID(uuidString: "EF520BC5-9EF2-4801-B395-DA0D146A4B65")




// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// PROTOCOL: CBInstrumentCentralManagerDelegate
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

/// This protocol defines the methods that a reporter delegate of a `CBInstrumentCentralManager` object must adopt. 
///
/// The only method of the protocol, `display(status:message:)`, requires that the reporter be able to present the status of the bluetooth connection to a user. The reporter delegate should be a `UIView` or `UIViewController` object, so that is can display the status to the user.
protocol CBInstrumentCentralManagerReporter: class {
    func display(status: InstrumentStatus, message: String?)
}

protocol DatabaseDelegate {
    func add(dataPoint: DataPoint)
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// CLASS: CBInstrumentCentralManager
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

/// The primary class to handle bluetooth connections to an instrument. 
///
/// Contains the methods to scan and connect to devices, determine the services the the device has, subscribe to charachteristics of that service, and recieve data from the charachteristics. This class calls on `CBDataParser` delegate to interpret the incoming data into local object instances (e.g. an `InstrumentDataPoint` object for incoming measumet data).
class CBInstrumentCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, CBDataParserDelegate, InstrummentConnectionViewControllerDelegate {
    
    
    
    // ----------------------------------------------------------------------
    // MARK: Constants
    // ----------------------------------------------------------------------
    
    /// Specifies the number of seconds to wait after a device scan is initiated to stop scanning
    let secondsToScanForPeripherals: TimeInterval = 20
    
    /// Queue to run bluetooth operation
    private let bleQueue = DispatchQueue.init(label: "bleQueue", qos: .utility)
    
    /// The delegate reporters to display the bluetooth connection to the user
    var statusReporters: [CBInstrumentCentralManagerReporter] = []
    
    /// The services that will be required to filter discovered devices, setting this value to `nil` will the central manager will discover all divices
    let requiredServices: [CBUUID]? = [uartServiceUUID]
    
    /// The peripherals that the manager will recognize and connect to upon discovering
    var rememberedPeripheralUUIDs = [legoSpecID]
    
    var connectionSessionID: UUID?
    
    var timeConverter: InstrumentTimeConverter?
    
    var databaseDelegate: DatabaseDelegate?
    
    var tempDataPointCache: Set<DataPoint> = []
    
    var tempInstrumentDataCache: Set<InstrumentDataPoint> = []
    
    // ----------------------------------------------------------------------
    // MARK: Computed Values
    // ----------------------------------------------------------------------
    
    /// The peripheral currently connected to the device
    var connectedPeripheral: CBPeripheral? {
        willSet {
            guard let peripheral = connectedPeripheral else { return }
            if newValue == nil {
                discoveredPeripherals[peripheral.identifier] = nil
            }
        }
    }
    
    /// the current status of the bluethooth connection, the `didSet` method will automatically update the status reporters when ever the status is changes through the `echoStatus()` methos
    var status: (status: InstrumentStatus, message: String?) = (.busy, "Initializing …") {
        didSet {
            if tempStatus != nil { tempStatus = nil }
            echoStatus()
        }
    }
    
    /// The status to load into `status` upon calling the `loadTempStatus()` method. Used primarily to display the "recieving data" status for a couple seconds before setting the status to "good" through a schedule timer.
    var tempStatus: (status: InstrumentStatus, message: String?)?
    
    
    /// Initializer for a `CBInstrumentCentralManager` object with a reporter delegate
    ///
    /// - Parameter reporter:
    init(withReporter reporter: CBInstrumentCentralManagerReporter) {
        super.init()
        statusReporters.append(reporter)
        centralManager = CBCentralManager(delegate: self, queue: bleQueue)
        dataParser = CBDataParser(withDelegate: self)
    }
    
    
    
    // ----------------------------------------------------------------------
    // MARK: - Central Manager, Central Manager Functions, & Delegate Functions
    // ----------------------------------------------------------------------

    /// Manages connected devices notifies of the state of bluetooth on the central device
    var centralManager: CBCentralManager!
    
    /// A boolean computed value that is true if bluetooth is turned on and false if not
    var isOn: Bool {
        if centralManager.state == .poweredOn { return true }
        else { return false }
    }
    
    
    /// Has the central manager scan for new devices.
    ///
    /// Checks to be sure the bluetooth is on then has the central manager scan for peripherals with the required sercices. This methos also schedules a timer to stop scanning after a specified time.
    func scanForPeripherals() {
        guard isOn else {
            print("BLE:_BLE not powered on, scan again after turning bluetooth on.")
            status =  (.warning, "Bluetooth off, please turn on.")
            return
        }
        discoveredPeripherals = [:]
        print("BLE:_BLE On!, scanning for peripherals")
        status = (.busy, "Scanning for avalible instruments … ")
        centralManager.scanForPeripherals(withServices: self.requiredServices, options: nil)
        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: self.secondsToScanForPeripherals, target: self, selector: #selector(self.stopScanningForPeripherals), userInfo: nil, repeats: false)
        }
    }
 
    /// Has the central manger stop scanning for peripherals and updates the bluetooth status.
    @objc private func stopScanningForPeripherals() {
        guard centralManager.isScanning else {
            return
        }
        centralManager.stopScan()
        status = (.warning, "Could not find any instruments.")
    }
    
    
    /// Called each time bluetooth state changes.
    ///
    /// - Parameter central: the central manager object whose state was updated
    ///
    /// This method is called each time bluetooth state changes; it is a method of the `CBCentralManagerDelegate` protocol. If the state changes to `.poweredOn` the central manger will scan for peripherals.
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("BLE:_Core Bluetooth Central Manager state changed!")
        if isOn {
            scanForPeripherals()
        } else {
            discoveredPeripherals = [:]
            status = (.warning, "Bluetooth off, please turn on.")
        }
        return
    }
    
    
    /// Called each time the central manager discovers a peripheral.
    ///
    /// - Parameters:
    ///   - central: the `CBCentralManager` instance which discovered a peripheral
    ///   - peripheral: the peripheral discovered
    ///   - advertisementData: a dictionary containing the advertisement data presented by the peripheral
    ///   - RSSI: the signal strength of the peripheral connection, (Received Signal Strength Indication)
    ///
    /// This method is called each time the central manager discovers a peripheral while scanning; it is a method of the `CBCentralManagerDelegate` protocol. The discovered peripheral will be added to a list of known peripherals as long as the peripheral has not been already discovered. If the discovered peripheral matches the list of known peripherals the central manager will attempt to to connect to that peripheral.
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let id = peripheral.identifier
        guard discoveredPeripherals[id] == nil && connectedPeripheral?.identifier != id else {
            print("BLE:_Peripherial already found.")
            return
        }
        print("BLE:_New perepherial found!")
        discoveredPeripherals[id] = peripheral
        
        if rememberedPeripheralUUIDs.contains(where: { $0 == id }) && connectedPeripheral == nil {
            print("BLE:_A known instrument was found!")
            centralManager.stopScan()
            centralManager.connect(peripheral)
            status.message = "Connecting to instrument …"
        }
    }
    
    /// Called if the central manager fails to connect to a peripheral.
    ///
    /// - Parameters:
    ///   - central: the `CBCentralManager` instance which failed to connect to the peripheral
    ///   - peripheral: the peripheral that could not be connected to
    ///   - error: an optional `Error` object that will be `nil` if there is no error, and contain an error if there is.
    internal func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("BLE:_Failed to connect to a peripheral")
        if let err = error {
            status = (.warning, "Could not connect to instrument." + err.localizedDescription)
        } else {
            status = (.warning, "Could not connect to instrument.")
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("BLE:_peripheral disconnected!")
        connectedPeripheral = nil
        connectionSessionID = nil
        status = (.warning, "Instrument disconected.")
        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.scanForPeripherals), userInfo: nil, repeats: false)
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("BLE:_Connected to a peripheral!")
        connectedPeripheral = peripheral
        connectionSessionID = UUID()
        peripheral.delegate = self
        peripheral.discoverServices([uartServiceUUID])
        print("BLE:_searcing for services....")
    }
    
    
    
    // ----------------------------------------------------------------------
    // MARK: - Peripheral Functions & Delegate Functions
    // ----------------------------------------------------------------------
    
    var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services,
            services.count > 0 && error == nil else {
                
            print("BLE:_ERROR: no services found. \(error?.localizedDescription ?? "")")
            status = (.warning, "Instrument configured incorrectly. \(error?.localizedDescription ?? "")")
            return
        }
        print("BLE:_Found a Service!")
  
        for service in services {
            if service.uuid == uartServiceUUID {
                print("BLE:_sucessfully connected to UART service")
                peripheral.discoverCharacteristics([uartRXCharID], for: service)
                print("BLE:_attemting to discover charachteristics …")
            }
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let charachteristics = service.characteristics,
            charachteristics.count > 0 && error == nil else {
                
            print("BLE:_ERROR: No charachteristics found. \(error?.localizedDescription ?? "")")
            status = (.warning, "Instrument configured incorrectly. \(error?.localizedDescription ?? "")")
            return
        }
        
        print("BLE:_\(charachteristics.count) charachteristic(s) found!")
        status = (.busy, "Subscibing to instrument data …")
        
        for c in charachteristics {
            switch c.uuid {
            case uartRXCharID:
                print("BLE:_Sucessfully found UART RX charachteristic...subscribing")
                peripheral.setNotifyValue(true, for: c)
                status = (.good, "Connected to instrument. Waiting for incoming data …")
                
            default:
                break
            }
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let data = characteristic.value else {
            print("BLE:_Charachteristic's value updated, but no data could be extracted.")
            return
        }
        dataParser.parse(data, fromPeripheral: peripheral, fromCharachteristic: characteristic)
    }
    
    
    
    // -----------------------------------------------------------------------
    // MARK: - Data Parser & Delegate Functions
    // ----------------------------------------------------------------------
    
    var dataParser: CBDataParser!
    
    func dataParser(_ dataParser: CBDataParser, didBeginParsingObjectWithTag tag: CBDataParser.ParsingTag, FromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic) {
        status = (.busy,"Recieving \(tag) …")
    }
    
    internal func dataParser(_ dataParser: CBDataParser, didRecieveObject parsedObject: Any, withTag tag: CBDataParser.ParsingTag, fromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic) {
        switch parsedObject {
        case let instrumentDP as InstrumentDataPoint:
            print("BLE:_Just got a data point!\n    --> \(instrumentDP)")
            if let tc = timeConverter {
                let dp = DataPoint(fromIDP: instrumentDP, usingTimeConverter: tc)
                if let delegate = databaseDelegate {
                    delegate.add(dataPoint: dp)
                } else {
                    tempDataPointCache.insert(dp)
                }
            } else {
                tempInstrumentDataCache.insert(instrumentDP)
            }
            
        case let instrumentMillis as UInt32:
            timeConverter = InstrumentTimeConverter(instrumentMillis: instrumentMillis)
        default:
            print("BLE:_Recieved an object, but it was of an unknown type.")
            break
        }
        tempStatus = (.good, "Recieved \(tag). Waiting for more incoming data …")
        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.loadTempStatus), userInfo: nil, repeats: false)
        }
    }

    @objc private func loadTempStatus() {
        guard let s = tempStatus else { return }
        status = s
    }
    
    
    
    // ----------------------------------------------------------------------
    // MARK: - Instrumment Connection View Controller Delegate Functions
    // ----------------------------------------------------------------------
    
    /// Delegate function to scan for devices.
    internal func rescanForDevices() {
        if let connectedPeripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
        } else {
            scanForPeripherals()
        }
    }
    
    /// Adds a new status reporter delegate to the central manager.
    ///
    /// - Parameter newReporter: the new reporter delegate to add
    ///
    /// Adds a new status reporter delegate to the instrument central manager and updates the new reporter delegate to the manager's current status.
    func addReporter(_ newReporter: CBInstrumentCentralManagerReporter) {
        statusReporters.append(newReporter)
        newReporter.display(status: status.status, message: status.message )
    }
    
    /// Removes the last reporter delegate from the `statusReporter` array
    func popReporter() {
        statusReporters.removeLast()
    }
    
    /// Updates each reporter delegate to the manager's current status
    func echoStatus() {
        for reporter in statusReporters {
            reporter.display(status: status.status, message: status.message)
        }
    }
    
}



