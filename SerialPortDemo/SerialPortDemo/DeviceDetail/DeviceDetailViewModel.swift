//
//  DeviceDetailViewModel.swift
//  SerialPortDemo
//
//  Created by Mark Feaver on 12/4/2024.
//

import SerialPort
import Foundation

@MainActor
final class DeviceDetailViewModel {

    // MARK: - Public Properties

    let device: SerialDeviceInfo

    // MARK: - Initialisers

    init(device: SerialDeviceInfo) {
        self.device = device
    }

}

// MARK: - View Configuration

extension DeviceDetailViewModel {

    var portName: String {
        device.portName
    }

    var vendorId: String {
        device.displayableVendorId ?? "Unknown"
    }

    var productId: String {
        device.displayableProductId ?? "Unknown"
    }

    var baudRate: String {
        String(device.baudRate.intValue)
    }

    var dataBits: String {
        switch device.dataBits {
        case .five:
            return "Five"
        case .six:
            return "Six"
        case .seven:
            return "Seven"
        case .eight:
            return "Eight"
        }
    }

    var parity: String {
        switch device.parity {
        case .none:
            return "None"
        case .odd:
            return "Odd"
        case .even:
            return "Even"
        }
    }

    var stopBits: String {
        switch device.stopBits {
        case .one:
            return "One"
        case .two:
            return "Two"
        }
    }

    var flowControl: String {
        switch device.flowControl {
        case .none:
            return "None"
        case .requestToSend:
            return "Request To Send/Clear To Send"
        case .xOnXOff:
            return "X On/X Off"
        case .requestToSendXOnXOff:
            return "Request To Send/Clear To Send and X On/X Off"
        }
    }

}
