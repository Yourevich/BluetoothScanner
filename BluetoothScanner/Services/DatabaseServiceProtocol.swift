//
//  DatabaseServiceProtocol.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 23.12.2024.
//

import Foundation

protocol DatabaseServiceProtocol {
    func saveOrUpdateDevice(name: String?, uuid: UUID, rssi: Int)
    func fetchAllDevices() -> [BluetoothDeviceEntity]
}
