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
                // SegmentedControl для переключения между режимами
                Picker("Mode", selection: $viewModel.currentMode) {
                    Text("Scanning").tag(MainViewModel.Mode.scanning)
                    Text("History").tag(MainViewModel.Mode.history)
                }
                .onChange(of: viewModel.currentMode) { mode in
                    print("Switched to mode: \(mode)")
                    if mode == .history {
                        viewModel.loadHistory()
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Отображение списка в зависимости от режима
                if viewModel.currentMode == .scanning {
                    List(viewModel.devices) { device in
                        VStack(alignment: .leading) {
                            Text(device.name).font(.headline)
                            Text("UUID: \(device.uuid)")
                            Text("RSSI: \(device.rssi)")
                        }
                    }
                } else if viewModel.currentMode == .history {
                    List(viewModel.history) { device in
                        VStack(alignment: .leading) {
                            Text(device.name).font(.headline)
                            Text("UUID: \(device.uuid)")
                            Text("Last Seen: \(device.lastSeenFormatted)")
                        }
                    }
                }

                // Кнопки управления сканированием
                if viewModel.currentMode == .scanning {
                    HStack {
                        Button("Start Scanning") {
                            viewModel.startScanning()
                        }
                        Button("Stop Scanning") {
                            viewModel.stopScanning()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Bluetooth Scanner")
        }
    }
}

extension BluetoothDevice {
    var lastSeenFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

#Preview {
    MainScanView()
}
