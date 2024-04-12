//
//  SerialDeviceInfo.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

public struct SerialDeviceInfo: Identifiable, Hashable {

    public let portName: String
    public let vendorId: Int?
    public let productId: Int?
    public let baudRate: BaudRate
    public let dataBits: DataBits
    public let stopBits: StopBits
    public let parity: Parity
    public let flowControl: FlowControl

    public init(
        portName: String,
        vendorId: Int?,
        productId: Int?,
        baudRate: BaudRate,
        dataBits: DataBits,
        stopBits: StopBits,
        parity: Parity,
        flowControl: FlowControl
    ) {
        self.portName = portName
        self.vendorId = vendorId
        self.productId = productId
        self.baudRate = baudRate
        self.dataBits = dataBits
        self.stopBits = stopBits
        self.parity = parity
        self.flowControl = flowControl
    }

    public var id: String {
        "\(portName)-\(displayableVendorId ?? "0")-\(displayableProductId ?? "0")"
    }

    public static func == (lhs: SerialDeviceInfo, rhs: SerialDeviceInfo) -> Bool {
        lhs.portName == rhs.portName
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

public extension SerialDeviceInfo {

    var displayableVendorId: String? {
        guard let vendorId else {
            return nil
        }
        return String(format: "0x%04X", vendorId)
    }

    var displayableProductId: String? {
        guard let productId else {
            return nil
        }
        return String(format: "0x%04X", productId)
    }

}

extension SerialDeviceInfo {

    init(portName: String, vendorId: Int?, productId: Int?, portProperties: SerialPortProperties) {
        self.init(
            portName: portName,
            vendorId: vendorId,
            productId: productId,
            baudRate: portProperties.baudRate,
            dataBits: portProperties.dataBits,
            stopBits: portProperties.stopBits,
            parity: portProperties.parity,
            flowControl: portProperties.flowControl
        )
    }

}
