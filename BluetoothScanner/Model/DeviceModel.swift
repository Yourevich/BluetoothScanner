//
//  DeviceModel.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation

struct BluetoothDevice: Identifiable {
    let id = UUID()
    let name: String
    let uuid: String
    let rssi: Int
}
