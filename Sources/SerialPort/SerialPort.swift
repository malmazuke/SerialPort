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

    var isOpen: Bool { get }
    var path: String { get }
    var name: String { get }

    var baudRate: BAUDRate { get set }
    var stopBits: StopBits { get set }
    var dataBits: DataBits { get set }
    var echoesReceivedData: Bool { get set }
    var parity: SerialPortParity { get set }

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

class StandardSerialPort: SerialPort {

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
        get {
            .rate(with: orsSerialPort.baudRate)
        }
        set {
            orsSerialPort.baudRate = newValue.intValue as NSNumber
        }
    }

    var stopBits: StopBits {
        get {
            .stopBits(with: orsSerialPort.numberOfStopBits)
        }
        set {
            orsSerialPort.numberOfStopBits = newValue.intValue
        }
    }

    var dataBits: DataBits {
        get {
            .dataBits(with: orsSerialPort.numberOfDataBits)
        }
        set {
            orsSerialPort.numberOfDataBits = newValue.intValue
        }
    }

    var echoesReceivedData: Bool {
        get {
            orsSerialPort.shouldEchoReceivedData
        }
        set {
            orsSerialPort.shouldEchoReceivedData = newValue
        }
    }

    var parity: SerialPortParity {
        get {
            .parity(with: orsSerialPort.parity)
        }
        set {
            orsSerialPort.parity = newValue.orsSerialPortParity
        }
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

        self.baudRate = configuration.baudRate
        self.stopBits = configuration.stopBits
        self.dataBits = configuration.dataBits
        self.echoesReceivedData = configuration.shouldEchoReceivedData
        self.parity = configuration.parity
        self.usesDTRDSRFlowControl = configuration.usesDTRDSRFlowControl
        self.usesRTSCTSFlowControl = configuration.usesRTSCTSFlowControl
        self.usesDCDOutputFlowControl = configuration.usesDCDOutputFlowControl
    }

}
