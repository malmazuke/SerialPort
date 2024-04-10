//
//  SerialPortManager.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

import Darwin
import Foundation
import IOKit.serial
import IOKit.usb

public protocol SerialPortManaging {

    var deviceEvents: AsyncStream<DeviceEvent> { get }

    func getConnectedDevices() throws -> [SerialDeviceInfo]

}

public class SerialPortManager: SerialPortManaging {

    // MARK: - Types

    private class ListenerWrapper {
        let continuation: AsyncStream<DeviceEvent>.Continuation
        init(continuation: AsyncStream<DeviceEvent>.Continuation) {
            self.continuation = continuation
        }
    }

    // MARK: - Public Properties

    public var deviceEvents: AsyncStream<DeviceEvent> {
        AsyncStream { continuation in
            let wrapper = ListenerWrapper(continuation: continuation)
            self.listeners.append(wrapper)
            continuation.onTermination = { [weak self] _ in
                self?.listeners.removeAll { $0 === wrapper }
            }
        }
    }

    // MARK: - Private Properties

    private var listeners = [ListenerWrapper]()
    private var connectedDevices: [String: SerialDeviceInfo] = [:]
    private var notificationPort: IONotificationPortRef?
    private var addedIterator: io_iterator_t = 0
    private var removedIterator: io_iterator_t = 0

    // MARK: - Initialisers

    public init() {
        configureDeviceMonitoring()
    }

    // MARK: - SerialPortManaging

    public func getConnectedDevices() throws -> [SerialDeviceInfo] {
        var devices: [SerialDeviceInfo] = []

        let matchingDictionary = IOServiceMatching(kIOSerialBSDServiceValue)
        var iterator: io_iterator_t = 0
        let kernResult = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDictionary, &iterator)

        guard kernResult == KERN_SUCCESS else {
            throw SerialPortError.failedToEnumerateDevices
        }

        while case let serialService = IOIteratorNext(iterator), serialService != 0 {
            defer { IOObjectRelease(serialService) }

            let deviceInfo = try extractDeviceInfo(from: serialService)
            devices.append(deviceInfo)
        }

        IOObjectRelease(iterator)
        return devices
    }

    // MARK: - Private Methods - Device Monitoring

    private func configureDeviceMonitoring() {
        let matchingDict = IOServiceMatching(kIOSerialBSDServiceValue)
        notificationPort = IONotificationPortCreate(kIOMainPortDefault)
        guard let notificationPort = notificationPort else { return }

        let runLoopSource = IONotificationPortGetRunLoopSource(notificationPort).takeRetainedValue()
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .defaultMode)

        // Watching for devices being added
        let addedCallback: IOServiceMatchingCallback = { (userData, iterator) in
            // Handle new devices
            let manager = Unmanaged<SerialPortManager>.fromOpaque(userData!).takeUnretainedValue()
            manager.deviceConnected(iterator: iterator)
        }

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        IOServiceAddMatchingNotification(
            notificationPort,
            kIOPublishNotification,
            matchingDict,
            addedCallback,
            selfPtr,
            &addedIterator
        )
        deviceConnected(iterator: addedIterator) // Check for already connected devices

        // Watching for devices being removed
        let removedCallback: IOServiceMatchingCallback = { (userData, iterator) in
            // Handle device removal
            let manager = Unmanaged<SerialPortManager>.fromOpaque(userData!).takeUnretainedValue()
            manager.deviceDisconnected(iterator: iterator)
        }

        IOServiceAddMatchingNotification(
            notificationPort,
            kIOTerminatedNotification,
            matchingDict,
            removedCallback,
            selfPtr,
            &removedIterator
        )
        deviceDisconnected(iterator: removedIterator) // Process any devices that were removed before monitoring started
    }

    private func deviceConnected(iterator: io_iterator_t) {
        while case let device = IOIteratorNext(iterator), device != 0 {
            defer { IOObjectRelease(device) }

            do {
                let deviceInfo = try extractDeviceInfo(from: device)
                connectedDevices[deviceInfo.portName] = deviceInfo

                listeners.forEach { $0.continuation.yield(.connected(deviceInfo)) }
            } catch {
                // Yield an error event
                listeners.forEach { $0.continuation.yield(.error(error)) }
            }
        }
    }

    private func deviceDisconnected(iterator: io_iterator_t) {
        while case let device = IOIteratorNext(iterator), device != 0 {
            defer { IOObjectRelease(device) }

            do {
                let portName = try extractPortName(from: device)

                if let deviceInfo = connectedDevices[portName] {
                    for listener in listeners {
                        listener.continuation.yield(.disconnected(deviceInfo))
                    }

                    connectedDevices.removeValue(forKey: portName)
                }
            } catch {
                listeners.forEach { $0.continuation.yield(.error(error)) }
            }
        }
    }

    // MARK: - Private Methods - Device Info

    private func extractDeviceInfo(from device: io_object_t) throws -> SerialDeviceInfo {
        let portName = try extractPortName(from: device)
        let usbProperties = extractVendorAndProductIds(from: device)
        let portProperties = try extractSerialPortProperties(portName: portName)

        return SerialDeviceInfo(
            portName: portName,
            vendorId: usbProperties.vendorId,
            productId: usbProperties.productId,
            portProperties: portProperties
        )
    }

    private func extractPortName(from device: io_object_t) throws -> String {
        guard let portName = IORegistryEntryCreateCFProperty(
            device,
            kIOCalloutDeviceKey as CFString,
            kCFAllocatorDefault,
            0
        ).takeRetainedValue() as? String else {
            throw SerialPortError.failedToExtractPortName
        }

        return portName
    }

    private func extractVendorAndProductIds(from device: io_object_t) -> (vendorId: Int?, productId: Int?) {
        var vendorId: Int?
        var productId: Int?
        var parentDevice: io_object_t = 0
        var currentDevice = device

        IOObjectRetain(device) // Ensure the original device is retained during traversal

        while IORegistryEntryGetParentEntry(currentDevice, kIOServicePlane, &parentDevice) == KERN_SUCCESS {
            defer { IOObjectRelease(currentDevice) }
            currentDevice = parentDevice

            if let vendorIdRef = IORegistryEntryCreateCFProperty(
                currentDevice,
                kUSBVendorID as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue() as? NSNumber {
                vendorId = vendorIdRef.intValue
            }

            if let productIdRef = IORegistryEntryCreateCFProperty(
                currentDevice,
                kUSBProductID as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue() as? NSNumber {
                productId = productIdRef.intValue
            }

            if vendorId != nil && productId != nil {
                break // Exit the loop once both IDs are found
            }
        }

        IOObjectRelease(currentDevice) // Release the last parentDevice obtained in the loop
        return (vendorId, productId)
    }

    private func extractSerialPortProperties(portName: String) throws -> SerialPortProperties {
        let fileDescriptor = open(portName, O_RDONLY | O_NOCTTY | O_NDELAY)
        guard fileDescriptor != -1 else {
            throw SerialPortError.failedToExtractPortProperties
        }

        defer {
            close(fileDescriptor)
        }

        var tty = termios()

        // Get current settings
        guard tcgetattr(fileDescriptor, &tty) == 0 else {
            throw SerialPortError.failedToExtractPortProperties
        }

        // Read and map baud rate
        let baudRate = BaudRate.rate(with: cfgetispeed(&tty))

        return SerialPortProperties(
            baudRate: baudRate,
            dataBits: tty.dataBits,
            parity: tty.parity,
            stopBits: tty.stopBits,
            flowControl: tty.flowControl
        )
    }

}

private extension termios {

    var dataBits: DataBits {
        let controlFlagSetting = (c_cflag & UInt(CSIZE))
        return DataBits.dataBits(with: UInt(controlFlagSetting))
    }

    var parity: Parity {
        let paritySetting = (c_cflag & UInt(PARENB))
        if paritySetting == 0 {
            return .none
        }
        if (c_cflag & UInt(PARODD)) != 0 {
            return .odd
        } else {
            return .even
        }
    }

    var stopBits: StopBits {
        (c_cflag & UInt(CSTOPB)) != 0 ? .two : .one
    }

    var flowControl: FlowControl {
        let hardwareFlowControl = (c_cflag & UInt((CRTS_IFLOW | CCTS_OFLOW))) != 0
        let softwareFlowControl = (c_iflag & UInt((IXON | IXOFF))) != 0

        switch (hardwareFlowControl, softwareFlowControl) {
        case (false, false):
            return .none
        case (true, false):
            return .requestToSend
        case (false, true):
            return .xOnXOff
        case (true, true):
            return .requestToSendXOnXOff
        }
    }

}
