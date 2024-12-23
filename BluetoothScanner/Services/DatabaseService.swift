//
//  DatabaseService.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation
import CoreData

final class DatabaseService {
    static let shared = DatabaseService()
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "BluetoothScannerModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error.localizedDescription)")
            }
        }
    }
    
    /// Сохранение или обновление устройства
    func saveOrUpdateDevice(name: String?, uuid: String, rssi: Int) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<BluetoothDeviceEntity> = BluetoothDeviceEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingDevice = results.first {
                existingDevice.rssi = Int32(rssi)
                existingDevice.lastSeen = Date()
            } else {
                let newDevice = BluetoothDeviceEntity(context: context)
                newDevice.name = name
                newDevice.uuid = uuid
                newDevice.rssi = Int32(rssi)
                newDevice.lastSeen = Date()
            }
            
            try context.save()
        } catch {
            print("Failed to save or update device: \(error.localizedDescription)")
        }
    }
    
    /// Получение всех устройств из базы
    func fetchAllDevices() -> [BluetoothDeviceEntity] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<BluetoothDeviceEntity> = BluetoothDeviceEntity.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
}
