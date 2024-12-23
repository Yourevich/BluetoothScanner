//
//  DeviceListView.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 23.12.2024.
//

import Foundation
import SwiftUI

struct DeviceListView: View {
    let devices: [BluetoothDevice]
    let showLastSeen: Bool
    let calculateSignalPercentage: (Int) -> Int

    var body: some View {
        List(devices) { device in
            HStack {
                VStack(alignment: .leading) {
                    Text(device.name).font(.headline)
                    Text("UUID: \(device.uuid)").font(.subheadline).foregroundColor(.gray)
                    if showLastSeen {
                        Text("Last Seen: \(device.lastSeenFormatted)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    } else {
                        Text("Status: \(device.status)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                    Text("\(calculateSignalPercentage(device.rssi))%")
                        .font(.caption)
                }
            }
            .padding(-10)
        }
    }
}
