//
//  DeviceDetailView.swift
//  SerialPortDemo
//
//  Created by Mark Feaver on 10/4/2024.
//

import SerialPort
import SwiftUI

struct DeviceDetailView: View {
    var device: SerialDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let device = device {
                Text("Port: \(device.portName)").font(.headline)
                Text("Vendor ID: \(formatId(device.vendorId))")
                Text("Product ID: \(formatId(device.productId))")
                Text("Baud Rate: \(device.baudRate.intValue)")
            } else {
                Text("Select a device to see its details.")
            }
        }
        .padding()
        .navigationTitle(device?.portName ?? "Device Details")
    }
    
    private func formatId(_ id: Int?) -> String {
        guard let id else {
            return "Unknown"
        }
        return String(format: "%04X", id)
    }
}

#Preview {
    DeviceDetailView()
}
