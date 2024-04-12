//
//  DeviceListView.swift
//  SerialPortDemo
//
//  Created by Mark Feaver on 10/4/2024.
//

import SwiftUI

@MainActor
struct DeviceListView: View {

    var viewModel = DeviceListViewModel()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Connected Devices")) {
                    ForEach(viewModel.devices, id: \.portName) { device in
                        Text(device.portName)
                            .onTapGesture {
                                viewModel.selectedDevice = device
                            }
                    }
                }

                Section(header: Text("Device Logs")) {
                    if viewModel.logMessages.isEmpty {
                        Text("No logs").foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.logMessages) { log in
                            Text(log.content).foregroundColor(log.logColour)
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 250)
            .navigationTitle("Devices")

            detailView
        }
    }

    @ViewBuilder
    private var detailView: some View {
        if let selectedDevice = viewModel.selectedDevice {
            DeviceDetailView(viewModel: DeviceDetailViewModel(device: selectedDevice))
        } else {
            EmptyDeviceDetailView()
        }
    }

}

extension DeviceListViewModel.LogMessage {

    var logColour: Color {
        switch self.type {
        case .debug:
            return .gray
        case .error:
            return .red
        }
    }
}

#Preview {
    DeviceListView()
}
