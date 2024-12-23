//
//  WelcomeCircleView.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 23.12.2024.
//

import Foundation
import SwiftUI

struct WelcomeCircleView: View {
    var body: some View {
        VStack {
            Spacer()
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 150, height: 150)
                .overlay(
                    Text("Начните\nсканирование")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                )
            Spacer()
        }
        .transition(.opacity)
    }
}
