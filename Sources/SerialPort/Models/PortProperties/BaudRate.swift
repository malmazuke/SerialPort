//
//  BaudRate.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

import Foundation

public enum BaudRate {

    case rate0
    case rate50
    case rate75
    case rate110
    case rate134
    case rate150
    case rate200
    case rate300
    case rate600
    case rate1200
    case rate1800
    case rate2400
    case rate4800
    case rate9600
    case rate19200
    case rate38400
    case rate7200
    case rate14400
    case rate28800
    case rate57600
    case rate76800
    case rate115200
    case rate230400
    case nonStandard(speed: UInt)

    var intValue: UInt {
        return switch self {
        case .rate0:
            0
        case .rate50:
            50
        case .rate75:
            75
        case .rate110:
            110
        case .rate134:
            134
        case .rate150:
            150
        case .rate200:
            200
        case .rate300:
            300
        case .rate600:
            600
        case .rate1200:
            1200
        case .rate1800:
            1800
        case .rate2400:
            2400
        case .rate4800:
            4800
        case .rate7200:
            7200
        case .rate9600:
            9600
        case .rate14400:
            14400
        case .rate19200:
            19200
        case .rate28800:
            28800
        case .rate38400:
            38400
        case .rate57600:
            57600
        case .rate76800:
            76800
        case .rate115200:
            115200
        case .rate230400:
            230400
        case .nonStandard(let speed):
            speed
        }
    }

}

public extension BaudRate {

    // swiftlint:disable:next cyclomatic_complexity
    static func rate(with speed: speed_t) -> BaudRate {
        return switch speed {
        case 0:
            .rate0
        case 50:
            .rate50
        case 75:
            .rate75
        case 110:
            .rate110
        case 134:
            .rate134
        case 150:
            .rate150
        case 200:
            .rate200
        case 300:
            .rate300
        case 600:
            .rate600
        case 1200:
            .rate1200
        case 1800:
            .rate1800
        case 2400:
            .rate2400
        case 4800:
            .rate4800
        case 7200:
            .rate7200
        case 9600:
            .rate9600
        case 14400:
            .rate14400
        case 19200:
            .rate19200
        case 28800:
            .rate28800
        case 38400:
            .rate38400
        case 57600:
            .rate57600
        case 76800:
            .rate76800
        case 115200:
            .rate115200
        case 230400:
            .rate230400
        default:
            .nonStandard(speed: speed)
        }
    }

}
