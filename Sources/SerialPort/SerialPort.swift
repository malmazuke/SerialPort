//
//  SerialPort.swift
//  
//
//  Created by Mark Feaver on 15/3/2024.
//

import Combine
import IOKit

///
/// A protocol defining essential functionality and properties of a connected serial device.
///
public protocol SerialPort {

    /// Indicates whether the serial device is currently open.
    var isOpen: Bool { get }

    /// The path to the serial device in the file system.
    var path: String { get }

    /// The human-readable name of the serial device.
    var name: String { get }

    /// The current baud rate of the serial device.
    var baudRate: BAUDRate { get set }

    /// The current number of stop bits used by the serial device.
    var stopBits: StopBits { get set }

    /// The current number of data bits used by the serial device.
    var dataBits: DataBits { get set }

    /// Indicates whether the serial device echoes received data back to the sender.
    var echoesReceivedData: Bool { get set }

    /// The current parity setting used by the serial device.
    var parity: SerialPortParity { get set }

    /// Indicates whether the serial device uses RTS/CTS flow control.
    var usesRTSCTSFlowControl: Bool { get set }

    /// Indicates whether the serial device uses DTR/DSR flow control.
    var usesDTRDSRFlowControl: Bool { get set }

    /// Indicates whether the serial device uses DCD output flow control.
    var usesDCDOutputFlowControl: Bool { get set }

    // MARK: - Port Pins

    /// The value of the RTS (Request to Send) pin on the serial device.
    var rts: Bool { get set }

    /// The value of the DTR (Data Terminal Ready) pin on the serial device.
    var dtr: Bool { get set }

    /// The value of the CTS (Clear to Send) pin on the serial device.
    var cts: Bool { get }

    /// The value of the DSR (Data Set Ready) pin on the serial device.
    var dsr: Bool { get }

    /// The value of the DCD (Data Carrier Detect) pin on the serial device.
    var dcd: Bool { get }

    /// The IOKit device object representing the serial device.
    var ioKitDevice: io_object_t { get }

}
