//
//  StandardSerialPort.swift
//
//
//  Created by Mark Feaver on 17/3/2024.
//

import Combine
import Foundation
import IOKit
import ORSSerial

///
/// A "Standard" implementation of the SerialPort protocol that simply does a passthrough to
/// an underlying ORSSerialPort, and abstracts away the reliance on delegates and NSNotificaitons.
///
public class StandardSerialPort: SerialPort {

    // MARK: - Types

    public struct SerialPortConfiguration {

        public let path: String
        public let baudRate: BAUDRate = .rate19200
        public let stopBits: StopBits = .one
        public let dataBits: DataBits = .eight
        public let parity: SerialPortParity = .none
        public let shouldEchoReceivedData: Bool = false
        public let usesRTSCTSFlowControl: Bool = false
        public let usesDTRDSRFlowControl: Bool = false
        public let usesDCDOutputFlowControl: Bool = false
        public let rts: Bool = false
        public let dtr: Bool = false

    }

    // MARK: - Public Properties

    public var isOpen: Bool {
        orsSerialPort.isOpen
    }

    public var path: String {
        orsSerialPort.path
    }

    public var name: String {
        orsSerialPort.name
    }

    public var baudRate: BAUDRate {
        get {
            .rate(with: orsSerialPort.baudRate)
        }
        set {
            orsSerialPort.baudRate = newValue.intValue as NSNumber
        }
    }

    public var stopBits: StopBits {
        get {
            .stopBits(with: orsSerialPort.numberOfStopBits)
        }
        set {
            orsSerialPort.numberOfStopBits = newValue.intValue
        }
    }

    public var dataBits: DataBits {
        get {
            .dataBits(with: orsSerialPort.numberOfDataBits)
        }
        set {
            orsSerialPort.numberOfDataBits = newValue.intValue
        }
    }

    public var echoesReceivedData: Bool {
        get {
            orsSerialPort.shouldEchoReceivedData
        }
        set {
            orsSerialPort.shouldEchoReceivedData = newValue
        }
    }

    public var parity: SerialPortParity {
        get {
            .parity(with: orsSerialPort.parity)
        }
        set {
            orsSerialPort.parity = newValue.orsSerialPortParity
        }
    }

    public var usesRTSCTSFlowControl: Bool {
        get {
            orsSerialPort.usesRTSCTSFlowControl
        }
        set {
            orsSerialPort.usesRTSCTSFlowControl = newValue
        }
    }

    public var usesDTRDSRFlowControl: Bool {
        get {
            orsSerialPort.usesDTRDSRFlowControl
        }
        set {
            orsSerialPort.usesDTRDSRFlowControl = newValue
        }
    }

    public var usesDCDOutputFlowControl: Bool {
        get {
            orsSerialPort.usesDCDOutputFlowControl
        }
        set {
            orsSerialPort.usesDCDOutputFlowControl = newValue
        }
    }

    public var rts: Bool {
        get {
            orsSerialPort.rts
        }
        set {
            orsSerialPort.rts = newValue
        }
    }

    public var dtr: Bool {
        get {
            orsSerialPort.dtr
        }
        set {
            orsSerialPort.dtr = newValue
        }
    }

    public var cts: Bool {
        orsSerialPort.cts
    }

    public var dsr: Bool {
        orsSerialPort.dsr
    }

    public var dcd: Bool {
        orsSerialPort.dcd
    }

    public var ioKitDevice: io_object_t {
        orsSerialPort.ioKitDevice
    }

    // MARK: - Private Properties

    private let orsSerialPort: ORSSerialPort

    ///
    /// Initialises a StandardSerialPort using the provided `SerialPortConfiguration`.
    ///
    /// - Parameters:
    ///   - configuration: An object containing values to configure the `StandardSerialPort`.
    ///
    /// ## See also
    /// - SerialPortConfiguration: Contains the full list of default values
    ///
    public required init?(configuration: SerialPortConfiguration) {
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

    ///
    /// Initialises a StandardSerialPort with default values.
    ///
    /// ## See also
    /// - SerialPortConfiguration: Contains the full list of default values
    ///
    public convenience init?(path: String) {
        self.init(configuration: SerialPortConfiguration(path: path))
    }

}
