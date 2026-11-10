// MARK: DiscoveredBeaconEntity
//
//  DiscoveredBeaconEntity.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 2026.
//
//  A MESH_BEACON_APP beacon heard during a discovery scan. Beacons advertise a
//  mesh's text message and, optionally, the channel / region / modem preset it
//  runs on. Discovery stores them per session so they can be displayed alongside
//  the per-preset results, and auto-adds any advertised preset to the scan queue.
//

import Foundation
import CoreData

@objc(DiscoveredBeaconEntity)
public class DiscoveredBeaconEntity: NSManagedObject {

	@NSManaged public var nodeNum: Int64
	@NSManaged public var shortName: String
	@NSManaged public var longName: String
	/// Human-readable beacon text (MeshBeacon.message).
	@NSManaged public var message: String
	/// RegionCodes raw value advertised by the beacon; 0 = unset / not offered.
	@NSManaged public var offerRegion: Int
	/// ModemPresets raw value advertised by the beacon, or -1 when the beacon
	/// didn't offer one. (0 is a valid preset — LongFast — so nil can't be 0.)
	@NSManaged public var offerPreset: Int
	/// Name of the channel the beacon offered, when it advertised one.
	@NSManaged public var offerChannelName: String
	/// Pre-shared key of the offered channel. Broadcast in the beacon (not a local secret), and
	/// required to actually tune to / join the advertised mesh.
	@NSManaged public var offerChannelPSK: Data
	@NSManaged public var hasOfferChannel: Bool
	/// Frequency slot the advertised mesh actually runs on, 1-based; 0 when the beacon
	/// did not carry one. A beacon sends this only when the mesh deliberately sits on a
	/// slot other than the one its region, channel name and preset would derive, so an
	/// absent value means "derive it" and a present one has to win over the derivation.
	@NSManaged public var offerFrequencySlot: Int
	@NSManaged public var snr: Float
	@NSManaged public var rssi: Int
	@NSManaged public var timestamp: Date
	/// The scan preset the radio was dwelling on when this beacon was heard.
	@NSManaged public var heardOnPresetName: String

	@NSManaged public var session: DiscoverySessionEntity?
	@NSManaged public var presetResult: DiscoveryPresetResultEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DiscoveredBeaconEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.nodeNum = 0
		self.shortName = ""
		self.longName = ""
		self.message = ""
		self.offerRegion = 0
		self.offerPreset = -1
		self.offerChannelName = ""
		self.offerChannelPSK = Data()
		self.hasOfferChannel = false
		self.offerFrequencySlot = 0
		self.snr = 0.0
		self.rssi = 0
		self.timestamp = Date()
		self.heardOnPresetName = ""
	}

	/// The advertised modem preset, or `nil` when the beacon didn't offer one.
	var offeredPreset: ModemPresets? {
		offerPreset >= 0 ? ModemPresets(rawValue: offerPreset) : nil
	}

	/// The slot the beacon pinned, or `nil` when it left the slot to be derived.
	var offeredFrequencySlot: Int? {
		offerFrequencySlot > 0 ? offerFrequencySlot : nil
	}

	/// The advertised region, or `nil` when unset.
	var offeredRegion: RegionCodes? {
		offerRegion > 0 ? RegionCodes(rawValue: offerRegion) : nil
	}

	/// A node label for display, preferring the long name, then short, then the hex id.
	var displayName: String {
		if !longName.isEmpty { return longName }
		if !shortName.isEmpty { return shortName }
		return String(format: "!%08x", UInt32(truncatingIfNeeded: nodeNum))
	}
}