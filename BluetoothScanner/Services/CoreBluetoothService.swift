//
//  CoreBluetoothService.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation
import CoreBluetooth
import Combine

final class CoreBluetoothService: NSObject, ObservableObject {
    // MARK: - Properties
    private var centralManager: CBCentralManager?
    private var discoveredDevicesSubject = PassthroughSubject<BluetoothDevice, Never>()
    @Published var discoveredDevices: [BluetoothDevice] = []
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Subscribe to device updates
        discoveredDevicesSubject
            .scan([]) { devices, newDevice in
                var updatedDevices = devices
                if !updatedDevices.contains(where: { $0.uuid == newDevice.uuid }) {
                    updatedDevices.append(newDevice)
                }
                return updatedDevices
            }
            .assign(to: &$discoveredDevices)
    }

    // MARK: - Public Methods
    func startScanning() {
        guard centralManager?.state == .poweredOn else {
            print("Bluetooth is not powered on")
            return
        }
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func stopScanning() {
        centralManager?.stopScan()
    }
}

// MARK: - CBCentralManagerDelegate
extension CoreBluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
        case .poweredOff:
            print("Bluetooth is powered off")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unsupported:
            print("Bluetooth is unsupported")
        case .resetting:
            print("Bluetooth is resetting")
        case .unknown:
            print("Bluetooth state is unknown")
        @unknown default:
            print("Unknown state")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let device = BluetoothDevice(
            name: peripheral.name ?? "Unknown",
            uuid: peripheral.identifier.uuidString,
            rssi: RSSI.intValue
        )
        discoveredDevicesSubject.send(device)
    }
}
