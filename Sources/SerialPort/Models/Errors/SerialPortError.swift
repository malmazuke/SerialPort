//
//  SerialPortError.swift
//
//
//  Created by Mark Feaver on 9/4/2024.
//

enum SerialPortError: Error {
    case failedToEnumerateDevices
    case failedToExtractPortName
}
