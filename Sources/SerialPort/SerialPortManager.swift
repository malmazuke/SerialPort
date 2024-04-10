//
//  SerialPortManager.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

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
                // Attempt to extract device information
                let deviceInfo = try extractDeviceInfo(from: device)
                // Yield a connected event for this device to all listeners
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
                // Attempt to extract device information
                let deviceInfo = try extractDeviceInfo(from: device)

                // Yield a disconnected event for this device to all listeners
                for listener in listeners {
                    listener.continuation.yield(.disconnected(deviceInfo))
                }
            } catch {
                listeners.forEach { $0.continuation.yield(.error(error)) }
            }
        }
    }

    // MARK: - Private Methods - Device Info

    private func extractDeviceInfo(from serialService: io_object_t) throws -> SerialDeviceInfo {
        guard let portName = IORegistryEntryCreateCFProperty(
            serialService,
            kIOCalloutDeviceKey as CFString,
            kCFAllocatorDefault,
            0
        ).takeRetainedValue() as? String else {
            throw SerialPortError.failedToExtractPortName
        }

        let portProperties = extractVendorAndProductIds(from: serialService)

        return SerialDeviceInfo(
            portName: portName,
            vendorId: portProperties.vendorId,
            productId: portProperties.productId
        )
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

}
