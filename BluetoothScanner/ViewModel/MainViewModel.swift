//
//  MainViewModel.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    private let bluetoothService = CoreBluetoothService()
    private let databaseService = DatabaseService.shared
    
    @Published var currentMode: Mode = .scanning
    @Published var devices: [BluetoothDevice] = []
    @Published var history: [BluetoothDevice] = []
    @Published var error: BluetoothError? // Для отображения ошибок
    
    private var cancellables = Set<AnyCancellable>()
    
    enum Mode {
        case scanning
        case history
    }
    
    init() {
        bluetoothService.$discoveredDevices
            .sink { [weak self] scannedDevices in
                guard let self = self, self.currentMode == .scanning else { return }
                self.devices = scannedDevices
                for device in scannedDevices {
                    self.databaseService.saveOrUpdateDevice(
                        name: device.name,
                        uuid: device.uuid,
                        rssi: device.rssi
                    )
                }
            }
            .store(in: &cancellables)
        
        bluetoothService.$error
            .sink { [weak self] error in
                self?.error = error
            }
            .store(in: &cancellables)
    }
    
    func loadHistory() {
        let savedEntities = databaseService.fetchAllDevices()
        history = savedEntities.map {
            BluetoothDevice(
                name: $0.name ?? "Unknown",
                uuid: $0.uuid ?? "",
                rssi: Int($0.rssi),
                lastSeen: $0.lastSeen ?? Date(),
                status: "Saved"
            )
        }
    }
    
    
    func updateMode(to mode: Mode) {
        currentMode = mode
        if mode == .history {
            loadHistory()
        }
    }
    
    func startScanning() {
        bluetoothService.startScanning()
    }
    
    func stopScanning() {
        bluetoothService.stopScanning()
    }
    
    func calculateSignalPercentage(rssi: Int) -> Int {
        max(0, min(100, (rssi + 100)))
    }
    
    func signalIcon() -> String {
        "chart.bar.fill"
    }
    
    func sortHistoryByName() {
        history.sort { $0.name < $1.name }
    }
    
    func sortHistoryByLastSeen() {
        history.sort { $0.lastSeen > $1.lastSeen }
    }
}

