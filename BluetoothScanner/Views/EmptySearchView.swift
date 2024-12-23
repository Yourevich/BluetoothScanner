//
//  WelcomeCircleView.swift
//  BluetoothScanner
//
//  Created by Илья Зорин on 23.12.2024.
//

import Foundation
import SwiftUI

struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 72))
            Text("Начните сканирование")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            Spacer()
        }
        .transition(.opacity)
    }
}
