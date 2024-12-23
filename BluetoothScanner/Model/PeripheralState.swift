//
//  PeripheralState.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 23.12.2024.
//

import Foundation

enum PeripheralState: String {
    case connected = "Connected"
    case connecting = "Connecting"
    case disconnected = "Disconnected"
    case disconnecting = "Disconnecting"
    case unknown = "Unknown"
}
