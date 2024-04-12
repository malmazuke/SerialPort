//
//  EmptyDeviceDetailView.swift
//  SerialPortDemo
//
//  Created by Mark Feaver on 12/4/2024.
//

import SwiftUI

struct EmptyDeviceDetailView: View {
    var body: some View {
        Text("Select a device to see its details")
            .navigationTitle("Device Details")
    }
}

#Preview {
    EmptyDeviceDetailView()
}
