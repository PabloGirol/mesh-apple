//
//  Bool.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 9/6/25.

extension Bool {

	static var iOS18: Bool {
		if #available(iOS 18, *) { return true }
		return false
	}

	static var macOS15: Bool {
		if #available(macOS 15, *) { return true }
		return false
	}

	static var os26: Bool {
		if #available(iOS 26, macOS 26, *) { return true }
		return false
	}
}
