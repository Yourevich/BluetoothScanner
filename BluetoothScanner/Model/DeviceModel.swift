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
    let lastSeen: Date
    let status: String
}


extension BluetoothDevice {
    var lastSeenFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: lastSeen)
    }
}
