//
//  MainViewModel.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    private let bluetoothService = CoreBluetoothService()
    private let databaseService = DatabaseService.shared

    // Переключение между режимами
    @Published var currentMode: Mode = .scanning
    @Published var devices: [BluetoothDevice] = []
    @Published var history: [BluetoothDevice] = []

    private var cancellables = Set<AnyCancellable>()

    enum Mode {
        case scanning
        case history
    }

    init() {
        // Подписываемся на найденные устройства в режиме сканирования
        bluetoothService.$discoveredDevices
            .sink { [weak self] scannedDevices in
                guard let self = self, self.currentMode == .scanning else { return }
                self.devices = scannedDevices

                // Сохраняем устройства в базу
                for device in scannedDevices {
                    self.databaseService.saveOrUpdateDevice(
                        name: device.name,
                        uuid: device.uuid,
                        rssi: device.rssi
                    )
                }
            }
            .store(in: &cancellables)
    }

    /// Переключение на историю: загрузка сохраненных устройств
    func loadHistory() {
        let savedEntities = databaseService.fetchAllDevices()
        print("Fetched \(savedEntities.count) devices from database:")
        for entity in savedEntities {
            print("Device UUID: \(entity.uuid ?? "No UUID"), Name: \(entity.name ?? "Unknown"), RSSI: \(entity.rssi), Last Seen: \(entity.lastSeen ?? Date())")
        }
        history = savedEntities.map {
            BluetoothDevice(
                name: $0.name ?? "Unknown",
                uuid: $0.uuid ?? "",
                rssi: Int($0.rssi)
            )
        }
        print("History updated: \(history)")
    }

    /// Обновление текущего режима
    func updateMode(to mode: Mode) {
        currentMode = mode
        print("Switched to mode: \(mode)")
        if mode == .history {
            loadHistory()
        }
    }

    /// Начало сканирования
    func startScanning() {
        bluetoothService.startScanning()
    }

    /// Остановка сканирования
    func stopScanning() {
        bluetoothService.stopScanning()
    }
}
