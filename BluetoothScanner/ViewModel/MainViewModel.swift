//
//  MainViewModel.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject, MainViewModelProtocol {
    
    private let bluetoothService: BluetoothServiceProtocol
    private let databaseService: DatabaseServiceProtocol

  
    @Published var currentMode: Mode = .scanning
    @Published var devices: [BluetoothDevice] = []
    @Published var history: [BluetoothDevice] = []
    @Published var error: BluetoothError?

    private var cancellables = Set<AnyCancellable>()

    
    enum Mode {
        case scanning
        case history
    }

    
    init(bluetoothService: BluetoothServiceProtocol,
         databaseService: DatabaseServiceProtocol) {
        self.bluetoothService = bluetoothService
        self.databaseService = databaseService

        setupBindings()
    }

   
    private func setupBindings() {
        bluetoothService.discoveredDevices
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.global(qos: .background))
            .sink { [weak self] scannedDevices in
                guard let self = self, self.currentMode == .scanning else { return }
                
               
                DispatchQueue.main.async {
                    self.devices = scannedDevices
                }
                
              
                DispatchQueue.global(qos: .background).async {
                    for device in scannedDevices {
                        self.databaseService.saveOrUpdateDevice(
                            name: device.name,
                            uuid: device.uuid,
                            rssi: device.rssi
                        )
                    }
                }
            }
            .store(in: &cancellables)

        bluetoothService.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.error = error
            }
            .store(in: &cancellables)
    }

   
    func loadHistory() {
        DispatchQueue.global(qos: .background).async {
            let savedEntities = self.databaseService.fetchAllDevices()
            let devices = savedEntities.map {
                BluetoothDevice(
                    name: $0.name ?? "Unknown",
                    uuid: $0.uuid ?? UUID(), // Convert Core Data's UUID
                    rssi: Int($0.rssi),
                    lastSeen: $0.lastSeen ?? Date(),
                    status: "Saved"
                )
            }
            DispatchQueue.main.async {
                self.history = devices
            }
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

   
    func clearError() {
        error = nil
    }
}




