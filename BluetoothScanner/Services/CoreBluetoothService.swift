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
    private var centralManager: CBCentralManager?
    private var discoveredDevicesSubject = PassthroughSubject<BluetoothDevice, Never>()
    @Published var discoveredDevices: [BluetoothDevice] = []
    @Published var error: BluetoothError? 

    private var discoveredDeviceUUIDs = Set<String>()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        discoveredDevicesSubject
            .scan([]) { devices, newDevice in
                var updatedDevices = devices
                if let index = updatedDevices.firstIndex(where: { $0.uuid == newDevice.uuid }) {
                    updatedDevices[index] = newDevice
                } else {
                    updatedDevices.append(newDevice)
                }
                return updatedDevices
            }
            .assign(to: &$discoveredDevices)
    }
    
    func startScanning() {
        guard let centralManager = centralManager else {
            error = .scanningFailed
            return
        }
        
        guard centralManager.state == .poweredOn else {
            error = .bluetoothOff
            return
        }
        
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func stopScanning() {
        centralManager?.stopScan()
    }
    
    private func mapPeripheralState(_ state: CBPeripheralState) -> String {
        switch state {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        case .disconnecting: return "Disconnecting"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension CoreBluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
            case .poweredOn:
                break
            case .poweredOff:
                error = .bluetoothOff
            case .unauthorized:
                error = .unauthorized
            case .unsupported:
                error = .unsupported
            case .resetting:
                error = .resetting
            case .unknown:
                error = .unknown
            @unknown default:
                error = .unknown
            }
        }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard !discoveredDeviceUUIDs.contains(peripheral.identifier.uuidString) else { return }
        discoveredDeviceUUIDs.insert(peripheral.identifier.uuidString)
        
        let device = BluetoothDevice(
            name: peripheral.name ?? "Unknown",
            uuid: peripheral.identifier.uuidString,
            rssi: RSSI.intValue,
            lastSeen: Date(),
            status: mapPeripheralState(peripheral.state)
        )
        
        discoveredDevicesSubject.send(device)
    }
}

