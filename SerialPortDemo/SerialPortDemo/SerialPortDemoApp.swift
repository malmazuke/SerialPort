//
//  SerialPortDemoApp.swift
//  SerialPortDemo
//
//  Created by Mark Feaver on 10/4/2024.
//

import SwiftUI

@main
struct SerialPortDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DeviceListView()
        }
    }
}
