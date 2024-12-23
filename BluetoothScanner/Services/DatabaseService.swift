//
//  DatabaseService.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import Foundation
import CoreData

final class DatabaseService: DatabaseServiceProtocol {
    static let shared = DatabaseService()
    private var container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "BluetoothScannerModel")
        
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = false
        description.shouldInferMappingModelAutomatically = false
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                if error.domain == NSCocoaErrorDomain && (error.code == 134100 || error.code == 134140) {
                    print("Core Data migration failed. Resetting database.")
                    self.resetDatabase()
                } else {
                    fatalError("Failed to load Core Data stack: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func resetDatabase() {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            fatalError("Failed to locate persistent store URL.")
        }
        
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: storeURL.path) {
                try fileManager.removeItem(at: storeURL)
                print("Old database deleted successfully.")
            }
            
            container = NSPersistentContainer(name: "BluetoothScannerModel")
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to reset database: \(error.localizedDescription)")
                }
                print("Database reset successfully.")
            }
        } catch {
            fatalError("Failed to remove old persistent store: \(error.localizedDescription)")
        }
    }
    
    func saveOrUpdateDevice(name: String?, uuid: UUID, rssi: Int) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<BluetoothDeviceEntity> = BluetoothDeviceEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        
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
    
    func fetchAllDevices() -> [BluetoothDeviceEntity] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<BluetoothDeviceEntity> = BluetoothDeviceEntity.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch devices: \(error.localizedDescription)")
            return []
        }
    }
}
