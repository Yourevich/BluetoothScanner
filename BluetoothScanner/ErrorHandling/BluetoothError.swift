//
//  BluetoothError.swift.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 23.12.2024.
//

import Foundation

enum BluetoothError: LocalizedError, Identifiable {
    case bluetoothOff
    case unauthorized
    case unsupported
    case resetting
    case unknown
    case scanningFailed
    case deviceAccessFailed

    var id: String {
        localizedDescription
    }

    var errorDescription: String? {
        switch self {
        case .bluetoothOff:
            return "Bluetooth is turned off. Please enable it in settings."
        case .unauthorized:
            return "Bluetooth access is unauthorized. Check your app permissions."
        case .unsupported:
            return "Bluetooth is not supported on this device."
        case .resetting:
            return "Bluetooth is temporarily unavailable. Try again later."
        case .unknown:
            return "Unknown Bluetooth state."
        case .scanningFailed:
            return "Failed to start scanning. Please try again."
        case .deviceAccessFailed:
            return "Failed to access device data. Please restart the app."
        }
    }
}
