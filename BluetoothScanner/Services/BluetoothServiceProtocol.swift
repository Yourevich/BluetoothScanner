//
//  BluetoothService.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 23.12.2024.
//

import Foundation
import Combine

protocol BluetoothServiceProtocol: AnyObject {
    var discoveredDevices: AnyPublisher<[BluetoothDevice], Never> { get }
    var error: AnyPublisher<BluetoothError?, Never> { get }
    func startScanning()
    func stopScanning()
}
