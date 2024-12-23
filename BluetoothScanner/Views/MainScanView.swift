//
//  ContentView.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 22.12.2024.
//

import SwiftUI

struct MainScanView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var showSortOptions = false
    @State private var isScanning = false
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    @State private var showErrorAlert = false
    
    init(bluetoothService: BluetoothServiceProtocol = CoreBluetoothService(),
         databaseService: DatabaseServiceProtocol = DatabaseService.shared) {
        _viewModel = StateObject(wrappedValue: MainViewModel(bluetoothService: bluetoothService, databaseService: databaseService))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ModePickerView(
                    currentMode: $viewModel.currentMode,
                    loadHistory: { viewModel.loadHistory() }
                )
                
                ZStack {
                    if isScanning {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Scanning...")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .transition(.opacity)
                    }
                }
                .padding(20)
                .animation(.easeInOut, value: isScanning)
                
                ZStack {
                    if viewModel.currentMode == .scanning && viewModel.devices.isEmpty && !isScanning {
                        EmptySearchView()
                    } else {
                        DeviceListView(
                            devices: viewModel.currentMode == .scanning ? viewModel.devices : viewModel.history,
                            showLastSeen: viewModel.currentMode == .history,
                            calculateSignalPercentage: viewModel.calculateSignalPercentage
                        )
                    }
                }
                .animation(.easeInOut, value: viewModel.devices.isEmpty)
                
                if viewModel.currentMode == .scanning {
                    HStack {
                        Button("Start Scanning") {
                            isScanning = true
                            viewModel.startScanning()
                            impactGenerator.impactOccurred()
                        }
                        .buttonStyle(FilledButtonStyle(color: .green))
                        
                        Button("Stop Scanning") {
                            isScanning = false
                            viewModel.stopScanning()
                            impactGenerator.impactOccurred()
                        }
                        .buttonStyle(FilledButtonStyle(color: .red))
                    }
                    .padding()
                }
            }
            .navigationTitle("Bluetooth Scanner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentMode == .history {
                        Button(action: { showSortOptions = true }) {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Sort Options", isPresented: $showSortOptions) {
                Button("By Name") {
                    viewModel.sortHistoryByName()
                }
                Button("By Last Seen") {
                    viewModel.sortHistoryByLastSeen()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert(item: $viewModel.error) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("OK")) {
                        viewModel.clearError()
                    }
                )
            }
            .task {
                impactGenerator.prepare() 
            }
        }
    }
}

#Preview {
    MainScanView()
}
