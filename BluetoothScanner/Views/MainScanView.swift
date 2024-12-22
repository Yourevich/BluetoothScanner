//
//  ContentView.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import SwiftUI

struct MainScanView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationView {
                    VStack {
                        List(viewModel.devices) { device in
                            VStack(alignment: .leading) {
                                Text(device.name).font(.headline)
                                Text("UUID: \(device.uuid)")
                                Text("RSSI: \(device.rssi)")
                            }
                        }

                        Button("Start Scanning") {
                            viewModel.startScanning()
                        }
                        .padding()
                    }
                    .navigationTitle("Bluetooth Scanner")
                }
            }
    }

#Preview {
    MainScanView()
}
