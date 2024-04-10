//
//  DeviceEvent.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

public enum DeviceEvent {

    case connected(SerialDeviceInfo)
    case disconnected(SerialDeviceInfo)
    case error(Error)

}
