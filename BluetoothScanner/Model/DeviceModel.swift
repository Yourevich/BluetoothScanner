//
//  DeviceModel.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation

//struct BluetoothDevice: Identifiable {
//    let id = UUID()
//    let name: String
//    let uuid: UUID 
//    let rssi: Int
//    let lastSeen: Date
//    let status: String
//}
//
//
extension BluetoothDevice {
    var lastSeenFormatted: String {
        DateFormatter.shortDateTimeFormatter.string(from: lastSeen)
    }
}

struct BluetoothDevice: Identifiable {
    var id: UUID { uuid } // Используем UUID устройства как идентификатор
    let name: String
    let uuid: UUID
    let rssi: Int
    let lastSeen: Date
    let status: String
}

