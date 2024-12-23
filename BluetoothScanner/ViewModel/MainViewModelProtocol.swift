//
//  MainViewModelProtocol.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 23.12.2024.
//

import Foundation

protocol MainViewModelProtocol: ObservableObject {
    var currentMode: MainViewModel.Mode { get set }
    var devices: [BluetoothDevice] { get }
    var history: [BluetoothDevice] { get }
    var error: BluetoothError? { get set }

    func loadHistory()
    func updateMode(to mode: MainViewModel.Mode)
    func startScanning()
    func stopScanning()
    func calculateSignalPercentage(rssi: Int) -> Int
    func signalIcon() -> String
    func sortHistoryByName()
    func sortHistoryByLastSeen()
}
