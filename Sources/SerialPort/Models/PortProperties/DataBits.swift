//
//  DataBits.swift
//
//
//  Created by Mark Feaver on 6/4/2024.
//

/// Represents the number of data bits in each character for serial communication.
public enum DataBits: UInt {

    /// Five data bits per character.
    case five = 5
    /// Six data bits per character.
    case six = 6
    /// Seven data bits per character.
    case seven = 7
    /// Eight data bits per character.
    case eight = 8

}
