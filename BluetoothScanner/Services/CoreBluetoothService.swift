//
//  CoreBluetoothService.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation
import CoreBluetooth
import Combine

//final class CoreBluetoothService: NSObject, ObservableObject, BluetoothServiceProtocol {
//
//    var discoveredDevices: AnyPublisher<[BluetoothDevice], Never> {
//        $publishedDiscoveredDevices.eraseToAnyPublisher()
//    }
//    var error: AnyPublisher<BluetoothError?, Never> {
//        $publishedError.eraseToAnyPublisher()
//    }
//
//    @Published private var publishedDiscoveredDevices: [BluetoothDevice] = []
//    @Published private var publishedError: BluetoothError?
//
//    private var centralManager: CBCentralManager?
//    private var discoveredDevicesSubject = PassthroughSubject<BluetoothDevice, Never>()
//    private var discoveredDeviceUUIDs = Set<UUID>()
//    private var cancellables = Set<AnyCancellable>()
//
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//
//        discoveredDevicesSubject
//            .scan([UUID: BluetoothDevice]()) { devices, newDevice in
//                var devices = devices
//                devices[newDevice.uuid] = newDevice
//                return devices
//            }
//            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.global(qos: .background))
//            .map { dict in dict.values.sorted(by: { $0.name < $1.name }) }
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$publishedDiscoveredDevices)
//    }
//
//    func startScanning() {
//        guard centralManager?.state == .poweredOn else {
//            publishedError = .bluetoothOff
//            return
//        }
//        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
//    }
//
//    func stopScanning() {
//        centralManager?.stopScan()
//    }
//
//    private func mapPeripheralState(_ state: CBPeripheralState) -> PeripheralState {
//        switch state {
//        case .connected:
//            return .connected
//        case .connecting:
//            return .connecting
//        case .disconnected:
//            return .disconnected
//        case .disconnecting:
//            return .disconnecting
//        @unknown default:
//            return .unknown
//        }
//    }
//}
//
//extension CoreBluetoothService: CBCentralManagerDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        switch central.state {
//        case .poweredOn:
//            publishedError = nil
//        case .poweredOff:
//            publishedError = .bluetoothOff
//        case .unauthorized:
//            publishedError = .unauthorized
//        case .unsupported:
//            publishedError = .unsupported
//        case .resetting:
//            publishedError = .resetting
//        case .unknown:
//            publishedError = .unknown
//        @unknown default:
//            publishedError = .unknown
//        }
//    }
//
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
//        guard !discoveredDeviceUUIDs.contains(peripheral.identifier) else { return }
//        discoveredDeviceUUIDs.insert(peripheral.identifier)
//
//        let device = BluetoothDevice(
//            name: peripheral.name ?? "Unknown",
//            uuid: peripheral.identifier, 
//            rssi: RSSI.intValue,
//            lastSeen: Date(),
//            status: mapPeripheralState(peripheral.state).rawValue
//        )
//
//        discoveredDevicesSubject.send(device)
//    }
//}

final class CoreBluetoothService: NSObject, ObservableObject, BluetoothServiceProtocol {

    var discoveredDevices: AnyPublisher<[BluetoothDevice], Never> {
        $publishedDiscoveredDevices.eraseToAnyPublisher()
    }
    var error: AnyPublisher<BluetoothError?, Never> {
        $publishedError.eraseToAnyPublisher()
    }

    @Published private var publishedDiscoveredDevices: [BluetoothDevice] = []
    @Published private var publishedError: BluetoothError?

    private var centralManager: CBCentralManager?
    private var discoveredDevicesSubject = PassthroughSubject<BluetoothDevice, Never>()
    private var discoveredDeviceUUIDs = Set<UUID>()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)

        discoveredDevicesSubject
            .scan([UUID: BluetoothDevice]()) { devices, newDevice in
                var devices = devices
                devices[newDevice.uuid] = newDevice
                return devices
            }
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.global(qos: .background))
            .map { dict in dict.values.sorted(by: { $0.name < $1.name }) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$publishedDiscoveredDevices)
    }

    func startScanning() {
        guard centralManager?.state == .poweredOn else {
            publishedError = .bluetoothOff
            return
        }
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }

    func stopScanning() {
        centralManager?.stopScan()
    }

    private func mapPeripheralState(_ state: CBPeripheralState) -> PeripheralState {
        switch state {
        case .connected:
            return .connected
        case .connecting:
            return .connecting
        case .disconnected:
            return .disconnected
        case .disconnecting:
            return .disconnecting
        @unknown default:
            return .unknown
        }
    }
}

extension CoreBluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            publishedError = nil
        case .poweredOff:
            publishedError = .bluetoothOff
        case .unauthorized:
            publishedError = .unauthorized
        case .unsupported:
            publishedError = .unsupported
        case .resetting:
            publishedError = .resetting
        case .unknown:
            publishedError = .unknown
        @unknown default:
            publishedError = .unknown
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard !discoveredDeviceUUIDs.contains(peripheral.identifier) else { return }
        discoveredDeviceUUIDs.insert(peripheral.identifier)

        let device = BluetoothDevice(
            name: peripheral.name ?? "Unknown",
            uuid: peripheral.identifier, // Используем UUID устройства из CoreBluetooth
            rssi: RSSI.intValue,
            lastSeen: Date(),
            status: mapPeripheralState(peripheral.state).rawValue
        )

        discoveredDevicesSubject.send(device)
    }
}


