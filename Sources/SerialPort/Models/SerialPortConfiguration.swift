//
//  SerialPortConfiguration.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

import Foundation

public struct SerialPortConfiguration {

    public let baudRate: BaudRate
    public let dataBits: DataBits
    public let stopBits: StopBits
    public let parity: Parity
    public let flowControl: FlowControl
    public let readTimeOut: TimeInterval?
    public let writeTimeOut: TimeInterval?

    init(
        baudRate: BaudRate = .rate9600,
        dataBits: DataBits = .eight,
        stopBits: StopBits = .one,
        parity: Parity = .none,
        flowControl: FlowControl = .none,
        readTimeOut: TimeInterval? = nil,
        writeTimeOut: TimeInterval? = nil
    ) {
        self.baudRate = baudRate
        self.dataBits = dataBits
        self.stopBits = stopBits
        self.parity = parity
        self.flowControl = flowControl
        self.readTimeOut = readTimeOut
        self.writeTimeOut = writeTimeOut
    }

}
