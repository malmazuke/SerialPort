//
//  DeviceDetailView.swift
//  SerialPortDemo
//
//  Created by Mark Feaver on 10/4/2024.
//

import SerialPort
import SwiftUI

@MainActor
struct DeviceDetailView: View {
    var viewModel: DeviceDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Port: \(viewModel.portName)").font(.headline)
            Text("Vendor ID: \(viewModel.vendorId)")
            Text("Product ID: \(viewModel.productId)")
            Text("Baud Rate: \(viewModel.baudRate)")
            Text("Data Bits: \(viewModel.dataBits)")
            Text("Stop Bits: \(viewModel.stopBits)")
            Text("Parity: \(viewModel.parity)")
            Text("Flow Control: \(viewModel.flowControl)")
        }
        .padding()
        .navigationTitle(viewModel.portName)
    }

}

#Preview {
    let testDevice = SerialDeviceInfo(
        portName: "/dev/abc-123",
        vendorId: 1234,
        productId: 4321,
        baudRate: .rate9600,
        dataBits: .eight,
        stopBits: .one,
        parity: .none,
        flowControl: .none
    )
    return DeviceDetailView(viewModel: DeviceDetailViewModel(device: testDevice))
}
