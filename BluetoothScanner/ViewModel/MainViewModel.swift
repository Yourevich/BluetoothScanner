//
//  MainViewModel.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation

final class MainViewModel: ObservableObject {
    private let bluetoothService = CoreBluetoothService()
    @Published var devices: [BluetoothDevice] = []

    init() {
        bluetoothService.$discoveredDevices
            .assign(to: &$devices)
    }

    func startScanning() {
        bluetoothService.startScanning()
    }

    func stopScanning() {
        bluetoothService.stopScanning()
    }
}
