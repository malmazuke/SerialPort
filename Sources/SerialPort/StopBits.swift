//
//  StopBits.swift
//  
//
//  Created by Mark Feaver on 15/3/2024.
//

public enum StopBits {

    case one
    case two
    case nonStandard(bits: UInt)

    var intValue: UInt {
        return switch self {
        case .one:
            1
        case .two:
            2
        case .nonStandard(bits: let bits):
            bits
        }
    }

}

public extension StopBits {

    static func stopBits(with value: UInt) -> StopBits {
        return switch value {
        case 1:
            .one
        case 2:
            .two
        default:
            .nonStandard(bits: value)
        }
    }

}
