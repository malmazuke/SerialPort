//
//  FlowControl.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

/// Defines flow control options for serial communication.
public enum FlowControl {

    /// No flow control. Best for simple connections where flow control is not needed.
    case none

    /// Uses RTS/CTS hardware signals for flow control. Suitable for preventing buffer overflow in high-speed transmissions.
    case requestToSend

    /// Uses XOn/XOff software signals for flow control. Good for environments where hardware flow control is not possible.
    case xOnXOff

    /// Combines RTS/CTS and XOn/XOff for flow control. Ideal for complex scenarios requiring robust data flow management.
    case requestToSendXOnXOff

}
