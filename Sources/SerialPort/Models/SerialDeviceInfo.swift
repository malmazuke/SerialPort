//
//  SerialDeviceInfo.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

public struct SerialDeviceInfo {

    public let portName: String
    public let vendorId: Int?
    public let productId: Int?
    public let baudRate: BaudRate
    public let dataBits: DataBits
    public let parity: Parity
    public let stopBits: StopBits
    public let flowControl: FlowControl

}

extension SerialDeviceInfo {

    init(portName: String, vendorId: Int?, productId: Int?, portProperties: SerialPortProperties) {
        self.init(
            portName: portName,
            vendorId: vendorId,
            productId: productId,
            baudRate: portProperties.baudRate,
            dataBits: portProperties.dataBits,
            parity: portProperties.parity,
            stopBits: portProperties.stopBits,
            flowControl: portProperties.flowControl
        )
    }

}
