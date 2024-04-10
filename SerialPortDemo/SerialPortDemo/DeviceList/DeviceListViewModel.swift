//
//  DeviceListViewModel.swift
//  SerialPortDemo
//
//  Created by Mark Feaver on 10/4/2024.
//

import Foundation
import Observation
import SerialPort

@Observable
@MainActor
class DeviceListViewModel {

    // MARK: - Types

    struct LogMessage: Identifiable {

        enum LogType {
            case debug
            case error
        }

        let id = UUID() // Automatically provides a unique identifier
        let content: String
        let type: LogType
    }

    // MARK: - Public Properties

    var devices: [SerialDeviceInfo] = []
    var logMessages: [LogMessage] = []
    var selectedDevice: SerialDeviceInfo?

    // MARK: - Private Properties

    private var serialPortManager: SerialPortManaging = SerialPortManager()

    // MARK: - Initialisers

    init() {
        setUpDeviceEvents()
        fetchDevices()
    }

    // MARK: - Public Methods

    func fetchDevices() {
        do {
            devices = try serialPortManager.getConnectedDevices()
        } catch {
            logMessages.append(LogMessage(content: "Failed to fetch devices: \(error.localizedDescription)", type: .error))
        }
    }

    // MARK: - Private Methods

    private func setUpDeviceEvents() {
        Task {
            for await event in serialPortManager.deviceEvents {
                switch event {
                case .connected(let deviceInfo):
                    logMessages.append(LogMessage(content: "Device connected: \(deviceInfo.portName)", type: .debug))
                    fetchDevices() // Refresh the device list
                case .disconnected(let deviceInfo):
                    logMessages.append(LogMessage(content: "Device disconnected: \(deviceInfo.portName)", type: .debug))
                    fetchDevices() // Refresh the device list
                case .error(let error):
                    logMessages.append(LogMessage(content: "Error: \(error.localizedDescription)", type: .error))
                }
            }
        }
    }

}
