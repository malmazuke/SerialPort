//
//  SerialPortParity.swift
//
//
//  Created by Mark Feaver on 15/3/2024.
//

import ORSSerial

public enum SerialPortParity {

    case none
    case odd
    case even

}

extension SerialPortParity {

    static func parity(with orsParity: ORSSerialPortParity) -> SerialPortParity {
        return switch orsParity {
        case .none:
            .none
        case .odd:
            .odd
        case .even:
            .even
        @unknown default:
            fatalError("ORSSerialPortParity only supports the above cases. If this changes, update this switch block.")
        }
    }

    var orsSerialPortParity: ORSSerialPortParity {
        switch self {
        case .none:
            return .none
        case .odd:
            return .odd
        case .even:
            return .even
        }
    }

}
