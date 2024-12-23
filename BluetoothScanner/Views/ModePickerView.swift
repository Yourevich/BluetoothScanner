//
//  ModePickerView.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 23.12.2024.
//

import Foundation
import SwiftUI

struct ModePickerView: View {
    @Binding var currentMode: MainViewModel.Mode
    var loadHistory: () -> Void

    var body: some View {
        Picker("Mode", selection: $currentMode) {
            Text("Scanning").tag(MainViewModel.Mode.scanning)
            Text("History").tag(MainViewModel.Mode.history)
        }
        .onChange(of: currentMode) { mode in
            if mode == .history {
                loadHistory()
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.top)
    }
}


