//
//  SerialPort.swift
//  
//
//  Created by Mark Feaver on 15/3/2024.
//

import Combine
import IOKit
import ORSSerial

public protocol SerialPort {

    // MARK: - Properties

    var isOpen: Bool { get }
    var path: String { get }
    var name: String { get }
    var baudRate: BAUDRate { get }
    var stopBits: StopBits { get }
    var dataBits: DataBits { get }
    var echoesReceivedData: Bool { get }
    var parity: SerialPortParity { get }

    var usesRTSCTSFlowControl: Bool { get set }
    var usesDTRDSRFlowControl: Bool { get set }
    var usesDCDOutputFlowControl: Bool { get set }

    // MARK: - Port Pins

    var rts: Bool { get set }
    var dtr: Bool { get set }
    var cts: Bool { get }
    var dsr: Bool { get }
    var dcd: Bool { get }

    var ioKitDevice: io_object_t { get }

    // MARK: - Initialisers

    init?(configuration: SerialPortConfiguration)

    // MARK: - Functions
}

public struct SerialPortConfiguration {

    let path: String
    let baudRate: BAUDRate = .rate19200
    let stopBits: StopBits = .one
    let dataBits: DataBits = .eight
    let parity: SerialPortParity = .none
    let shouldEchoReceivedData: Bool = false
    let usesRTSCTSFlowControl: Bool = false
    let usesDTRDSRFlowControl: Bool = false
    let usesDCDOutputFlowControl: Bool = false
    let rts: Bool = false
    let dtr: Bool = false

}

class DefaultSerialPort: SerialPort {

    var isOpen: Bool {
        orsSerialPort.isOpen
    }

    var path: String {
        orsSerialPort.path
    }

    var name: String {
        orsSerialPort.name
    }

    var baudRate: BAUDRate {
        .rate(with: orsSerialPort.baudRate)
    }

    var stopBits: StopBits {
        .stopBits(with: orsSerialPort.numberOfStopBits)
    }

    var dataBits: DataBits {
        .dataBits(with: orsSerialPort.numberOfDataBits)
    }

    var echoesReceivedData: Bool {
        orsSerialPort.shouldEchoReceivedData
    }

    var parity: SerialPortParity {
        .parity(with: orsSerialPort.parity)
    }

    var usesRTSCTSFlowControl: Bool {
        get {
            orsSerialPort.usesRTSCTSFlowControl
        }
        set {
            orsSerialPort.usesRTSCTSFlowControl = newValue
        }
    }

    var usesDTRDSRFlowControl: Bool {
        get {
            orsSerialPort.usesDTRDSRFlowControl
        }
        set {
            orsSerialPort.usesDTRDSRFlowControl = newValue
        }
    }

    var usesDCDOutputFlowControl: Bool {
        get {
            orsSerialPort.usesDCDOutputFlowControl
        }
        set {
            orsSerialPort.usesDCDOutputFlowControl = newValue
        }
    }

    var rts: Bool {
        get {
            orsSerialPort.rts
        }
        set {
            orsSerialPort.rts = newValue
        }
    }

    var dtr: Bool {
        get {
            orsSerialPort.dtr
        }
        set {
            orsSerialPort.dtr = newValue
        }
    }

    var cts: Bool {
        orsSerialPort.cts
    }

    var dsr: Bool {
        orsSerialPort.dsr
    }

    var dcd: Bool {
        orsSerialPort.dcd
    }

    var ioKitDevice: io_object_t {
        orsSerialPort.ioKitDevice
    }

    // MARK: - Private Properties

    private let orsSerialPort: ORSSerialPort

    required init?(configuration: SerialPortConfiguration) {
        guard let serialPort = ORSSerialPort(path: configuration.path) else {
            return nil
        }

        self.orsSerialPort = serialPort

        configureORSSerialPort(orsSerialPort: self.orsSerialPort, withConfiguration: configuration)
    }

    private func configureORSSerialPort(
        orsSerialPort: ORSSerialPort,
        withConfiguration configuration: SerialPortConfiguration
    ) {
        orsSerialPort.baudRate = configuration.baudRate.intValue as NSNumber
        orsSerialPort.numberOfStopBits = configuration.stopBits.intValue
        orsSerialPort.numberOfDataBits = configuration.dataBits.intValue
        orsSerialPort.shouldEchoReceivedData = configuration.shouldEchoReceivedData
        orsSerialPort.parity = configuration.parity.orsSerialPortParity
        orsSerialPort.usesDTRDSRFlowControl = configuration.usesDTRDSRFlowControl
        orsSerialPort.usesRTSCTSFlowControl = configuration.usesRTSCTSFlowControl
        orsSerialPort.usesDCDOutputFlowControl = configuration.usesDCDOutputFlowControl
    }

}
