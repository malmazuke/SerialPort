//
//  DataBits.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

public enum DataBits {

    case five
    case six
    case seven
    case eight
    case nonStandard(bits: UInt)

    var intValue: UInt {
        return switch self {
        case .five:
            5
        case .six:
            6
        case .seven:
            7
        case .eight:
            8
        case .nonStandard(bits: let bits):
            bits
        }
    }

}

public extension DataBits {

    static func dataBits(with value: UInt) -> DataBits {
        return switch value {
        case 5:
            .five
        case 6:
            .six
        case 7:
            .seven
        case 8:
            .eight
        default:
            .nonStandard(bits: value)
        }
    }

}
