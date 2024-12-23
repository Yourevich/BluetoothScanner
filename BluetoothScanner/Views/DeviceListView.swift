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
            VStack(alignment: .leading, spacing: 8) {
                Text(device.name)
                    .font(.headline)
                    .lineLimit(1)

                Text("UUID: \(device.uuid)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                if showLastSeen {
                    Text("Last Seen: \(device.lastSeenFormatted)")
                        .font(.footnote)
                        .foregroundColor(.blue)
                } else {
                    Text("Status: \(device.status)")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }

                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                    Text("\(calculateSignalPercentage(device.rssi))%")
                        .font(.caption)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            )
            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
        }
        .listStyle(PlainListStyle())
    }
}
