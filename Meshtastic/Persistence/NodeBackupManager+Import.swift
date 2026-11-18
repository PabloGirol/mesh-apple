//
//  NodeBackupManager+Import.swift
//  Meshtastic
//
//  Copyright(c) Meshtastic 2025.
//

import CoreData

extension NodeBackupManager {

	// MARK: - Import Helpers

	nonisolated static func importNodes(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext) throws -> [Int64: NodeInfoEntity] {
		let request = NSFetchRequest<NodeInfoEntity>(entityName: "NodeInfoEntity")
		let backupNodes = try backupContext.fetch(request)
		var nodesByNum: [Int64: NodeInfoEntity] = [:]
		for src in backupNodes {
			let dst = NodeInfoEntity(context: liveContext)
			dst.bleName = src.bleName
			dst.channel = src.channel
			dst.favorite = src.favorite
			dst.firstHeard = src.firstHeard
			dst.hasBeenAdministered = src.hasBeenAdministered
			dst.hasXeddsaSigned = src.hasXeddsaSigned
			dst.heardOnCurrentLora = src.heardOnCurrentLora
			dst.hopsAway = src.hopsAway
			dst.id = src.id
			dst.ignored = src.ignored
			dst.isKeyManuallyVerified = src.isKeyManuallyVerified
			dst.lastHeard = src.lastHeard
			dst.nodeStatus = src.nodeStatus
			dst.num = src.num
			dst.peripheralId = src.peripheralId
			dst.powerChannelLabels = src.powerChannelLabels
			dst.rssi = src.rssi
			dst.sessionExpiration = src.sessionExpiration
			dst.sessionPasskey = src.sessionPasskey
			dst.snr = src.snr
			dst.viaMqtt = src.viaMqtt
			nodesByNum[dst.num] = dst
		}
		return nodesByNum
	}

	nonisolated static func importUsers(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext, nodesByNum: [Int64: NodeInfoEntity]) throws -> [Int64: UserEntity] {
		let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
		let backupUsers = try backupContext.fetch(request)
		var usersByNum: [Int64: UserEntity] = [:]
		for src in backupUsers {
			// Each `dst` is a freshly-created entity that we insert into the live context — this copy never
			// overwrites the public key of an already-populated *live* record, so the inbound-mesh
			// first-wins key protection (UpdateSwiftData / MeshPackets) doesn't apply here. This is a
			// user-initiated restore of the user's own trusted backup, carrying `keyMatch`/`newPublicKey`
			// forward verbatim.
			let dst = UserEntity(context: liveContext)
			dst.hwDisplayName = src.hwDisplayName
			dst.hwModel = src.hwModel
			dst.hwModelId = src.hwModelId
			dst.isLicensed = src.isLicensed
			dst.keyMatch = src.keyMatch
			dst.lastMessage = src.lastMessage
			dst.longName = src.longName
			dst.mute = src.mute
			dst.newPublicKey = src.newPublicKey
			dst.num = src.num
			dst.numString = src.numString
			dst.pkiEncrypted = src.pkiEncrypted
			dst.publicKey = src.publicKey
			dst.role = src.role
			dst.shortName = src.shortName
			dst.unmessagable = src.unmessagable
			dst.userId = src.userId
			if let srcNode = src.userNode, let liveNode = nodesByNum[srcNode.num] {
				dst.userNode = liveNode
			}
			usersByNum[dst.num] = dst
		}
		return usersByNum
	}

	nonisolated static func importMyInfo(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext, nodesByNum: [Int64: NodeInfoEntity]) throws -> [Int64: MyInfoEntity] {
		let request = NSFetchRequest<MyInfoEntity>(entityName: "MyInfoEntity")
		let backupMyInfos = try backupContext.fetch(request)
		var myInfosByNodeNum: [Int64: MyInfoEntity] = [:]
		for src in backupMyInfos {
			let dst = MyInfoEntity(context: liveContext)
			dst.bleName = src.bleName
			dst.deviceId = src.deviceId
			dst.minAppVersion = src.minAppVersion
			dst.myNodeNum = src.myNodeNum
			dst.peripheralId = src.peripheralId
			dst.pioEnv = src.pioEnv
			dst.rebootCount = src.rebootCount
			dst.registered = src.registered
			if let srcNode = src.myInfoNode, let liveNode = nodesByNum[srcNode.num] {
				dst.myInfoNode = liveNode
				myInfosByNodeNum[srcNode.num] = dst
			}
		}
		return myInfosByNodeNum
	}

	nonisolated static func importChannels(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext, myInfosByNodeNum: [Int64: MyInfoEntity]) throws {
		let request = NSFetchRequest<ChannelEntity>(entityName: "ChannelEntity")
		let backupChannels = try backupContext.fetch(request)
		for src in backupChannels {
			let dst = ChannelEntity(context: liveContext)
			dst.downlinkEnabled = src.downlinkEnabled
			dst.id = src.id
			dst.index = src.index
			dst.mute = src.mute
			dst.name = src.name
			dst.positionPrecision = src.positionPrecision
			dst.psk = src.psk
			dst.role = src.role
			dst.uplinkEnabled = src.uplinkEnabled
			if let srcMyInfo = src.myInfoChannel,
			   let srcNode = srcMyInfo.myInfoNode,
			   let liveMyInfo = myInfosByNodeNum[srcNode.num] {
				dst.myInfoChannel = liveMyInfo
			}
		}
	}

	nonisolated static func importMetadata(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext, nodesByNum: [Int64: NodeInfoEntity]) throws {
		let request = NSFetchRequest<DeviceMetadataEntity>(entityName: "DeviceMetadataEntity")
		let backupMetadata = try backupContext.fetch(request)
		for src in backupMetadata {
			let dst = DeviceMetadataEntity(context: liveContext)
			dst.canShutdown = src.canShutdown
			dst.deviceStateVersion = src.deviceStateVersion
			dst.excludedModules = src.excludedModules
			dst.firmwareVersion = src.firmwareVersion
			dst.hasBluetooth = src.hasBluetooth
			dst.hasEthernet = src.hasEthernet
			dst.hasWifi = src.hasWifi
			dst.hasXeddsa = src.hasXeddsa
			dst.hwModel = src.hwModel
			dst.positionFlags = src.positionFlags
			dst.role = src.role
			dst.time = src.time
			dst.displayWidth = src.displayWidth
			dst.displayHeight = src.displayHeight
			dst.displayFormat = src.displayFormat
			dst.displayPanelClass = src.displayPanelClass
			dst.displayHasTouch = src.displayHasTouch
			if let srcNode = src.metadataNode, let liveNode = nodesByNum[srcNode.num] {
				dst.metadataNode = liveNode
			}
		}
	}

	nonisolated static func importPositions(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext, nodesByNum: [Int64: NodeInfoEntity]) throws {
		let request = NSFetchRequest<PositionEntity>(entityName: "PositionEntity")
		let backupPositions = try backupContext.fetch(request)
		for src in backupPositions {
			let dst = PositionEntity(context: liveContext)
			dst.altitude = src.altitude
			dst.heading = src.heading
			dst.latest = src.latest
			dst.latitudeI = src.latitudeI
			dst.longitudeI = src.longitudeI
			dst.precisionBits = src.precisionBits
			dst.rssi = src.rssi
			dst.satsInView = src.satsInView
			dst.seqNo = src.seqNo
			dst.snr = src.snr
			dst.speed = src.speed
			dst.time = src.time
			if let srcNode = src.nodePosition, let liveNode = nodesByNum[srcNode.num] {
				dst.nodePosition = liveNode
				if dst.latest { liveNode.latestPositionCache = dst }
			}
		}
	}

	nonisolated static func importTelemetry(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext, nodesByNum: [Int64: NodeInfoEntity]) throws {
		let request = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		let backupTelemetry = try backupContext.fetch(request)
		for src in backupTelemetry {
			// Backups made before `nodeNum` existed only link the row to its node, so fall back
			// to that. Rows whose node is not in the backup were never shown, so they stay out.
			guard let nodeNum = src.ownerNodeNum, nodesByNum[nodeNum] != nil else { continue }
			let dst = TelemetryEntity(context: liveContext)
			dst.metricsType = src.metricsType
			dst.time = src.time
			dst.airUtilTx = src.airUtilTx
			dst.barometricPressure = src.barometricPressure
			dst.batteryLevel = src.batteryLevel
			dst.channelUtilization = src.channelUtilization
			dst.current = src.current
			dst.distance = src.distance
			dst.gasResistance = src.gasResistance
			dst.iaq = src.iaq
			dst.irLux = src.irLux
			dst.lux = src.lux
			dst.numOnlineNodes = src.numOnlineNodes
			dst.numPacketsRx = src.numPacketsRx
			dst.numPacketsRxBad = src.numPacketsRxBad
			dst.numPacketsTx = src.numPacketsTx
			dst.numRxDupe = src.numRxDupe
			dst.numTotalNodes = src.numTotalNodes
			dst.numTxRelay = src.numTxRelay
			dst.numTxRelayCanceled = src.numTxRelayCanceled
			dst.noiseFloor = src.noiseFloor
			dst.pm10Environmental = src.pm10Environmental
			dst.pm10Standard = src.pm10Standard
			dst.pm25Environmental = src.pm25Environmental
			dst.pm25Standard = src.pm25Standard
			dst.pm100Environmental = src.pm100Environmental
			dst.pm100Standard = src.pm100Standard
			dst.powerCh1Current = src.powerCh1Current
			dst.powerCh1Voltage = src.powerCh1Voltage
			dst.powerCh2Current = src.powerCh2Current
			dst.powerCh2Voltage = src.powerCh2Voltage
			dst.powerCh3Current = src.powerCh3Current
			dst.powerCh3Voltage = src.powerCh3Voltage
			dst.radiation = src.radiation
			dst.rainfall1H = src.rainfall1H
			dst.rainfall24H = src.rainfall24H
			dst.relativeHumidity = src.relativeHumidity
			dst.rssi = src.rssi
			dst.snr = src.snr
			dst.soilMoisture = src.soilMoisture
			dst.soilTemperature = src.soilTemperature
			dst.temperature = src.temperature
			dst.uptimeSeconds = src.uptimeSeconds
			dst.uvLux = src.uvLux
			dst.voltage = src.voltage
			dst.weight = src.weight
			dst.whiteLux = src.whiteLux
			dst.windDirection = src.windDirection
			dst.windGust = src.windGust
			dst.windLull = src.windLull
			dst.windSpeed = src.windSpeed
			dst.nodeNum = nodeNum
		}
	}

	nonisolated static func importMessages(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext, usersByNum: [Int64: UserEntity]) throws {
		let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
		let backupMessages = try backupContext.fetch(request)
		for src in backupMessages {
			let dst = MessageEntity(context: liveContext)
			dst.ackError = src.ackError
			dst.ackSNR = src.ackSNR
			dst.ackTimestamp = src.ackTimestamp
			dst.admin = src.admin
			dst.adminDescription = src.adminDescription
			dst.channel = src.channel
			dst.isEmoji = src.isEmoji
			dst.messageId = src.messageId
			dst.messagePayload = src.messagePayload
			dst.messagePayloadMarkdown = src.messagePayloadMarkdown
			dst.messagePayloadTranslated = src.messagePayloadTranslated
			dst.messagePayloadTranslatedMarkdown = src.messagePayloadTranslatedMarkdown
			dst.messageTimestamp = src.messageTimestamp
			dst.pkiEncrypted = src.pkiEncrypted
			dst.portNum = src.portNum
			dst.publicKey = src.publicKey
			dst.read = src.read
			dst.realACK = src.realACK
			dst.receivedACK = src.receivedACK
			dst.relayNode = src.relayNode
			dst.relays = src.relays
			dst.replyID = src.replyID
			dst.rssi = src.rssi
			dst.showTranslatedMessage = src.showTranslatedMessage
			dst.snr = src.snr
			dst.xeddsaSigned = src.xeddsaSigned
			if let fromNum = src.fromUser?.num, let liveUser = usersByNum[fromNum] {
				dst.fromUser = liveUser
			}
			if let toNum = src.toUser?.num, let liveUser = usersByNum[toNum] {
				dst.toUser = liveUser
			}
		}
	}

	nonisolated static func importWaypoints(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext) throws {
		let request = NSFetchRequest<WaypointEntity>(entityName: "WaypointEntity")
		let backupWaypoints = try backupContext.fetch(request)
		for src in backupWaypoints {
			let dst = WaypointEntity(context: liveContext)
			dst.created = src.created
			dst.createdBy = src.createdBy
			dst.expire = src.expire
			dst.icon = src.icon
			dst.id = src.id
			dst.lastUpdated = src.lastUpdated
			dst.lastUpdatedBy = src.lastUpdatedBy
			dst.latitudeI = src.latitudeI
			dst.locked = src.locked
			dst.isLocal = src.isLocal
			dst.longDescription = src.longDescription
			dst.longitudeI = src.longitudeI
			dst.name = src.name
			dst.geofenceRadius = src.geofenceRadius
			dst.hasBoundingBox = src.hasBoundingBox
			dst.boundingBoxLatitudeNorthI = src.boundingBoxLatitudeNorthI
			dst.boundingBoxLatitudeSouthI = src.boundingBoxLatitudeSouthI
			dst.boundingBoxLongitudeEastI = src.boundingBoxLongitudeEastI
			dst.boundingBoxLongitudeWestI = src.boundingBoxLongitudeWestI
			dst.notifyOnEnter = src.notifyOnEnter
			dst.notifyOnExit = src.notifyOnExit
			dst.notifyFavoritesOnly = src.notifyFavoritesOnly
		}
	}

	nonisolated static func importTraceRoutes(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext, nodesByNum: [Int64: NodeInfoEntity]) throws {
		let request = NSFetchRequest<TraceRouteEntity>(entityName: "TraceRouteEntity")
		let backupTraceRoutes = try backupContext.fetch(request)
		for src in backupTraceRoutes {
			let dst = TraceRouteEntity(context: liveContext)
			dst.id = src.id
			dst.hasPositions = src.hasPositions
			dst.hopsBack = src.hopsBack
			dst.hopsTowards = src.hopsTowards
			dst.response = src.response
			dst.routeBackText = src.routeBackText
			dst.routeText = src.routeText
			dst.sent = src.sent
			dst.snr = src.snr
			dst.time = src.time
			dst.sentAt = src.sentAt
			dst.rateLimited = src.rateLimited
			dst.fromNum = src.fromNum
			dst.toNum = src.toNum
			if let srcNode = src.node, let liveNode = nodesByNum[srcNode.num] {
				dst.node = liveNode
			}
			for srcHop in src.hops {
				let dstHop = TraceRouteHopEntity(context: liveContext)
				dstHop.back = srcHop.back
				dstHop.index = srcHop.index
				dstHop.name = srcHop.name
				dstHop.num = srcHop.num
				dstHop.snr = srcHop.snr
				dstHop.time = srcHop.time
				dstHop.traceRoute = dst
			}
			for srcPosition in src.nodePositions {
				let dstPosition = TraceRouteNodePositionEntity(context: liveContext)
				dstPosition.num = srcPosition.num
				dstPosition.altitude = srcPosition.altitude
				dstPosition.heading = srcPosition.heading
				dstPosition.latitudeI = srcPosition.latitudeI
				dstPosition.longitudeI = srcPosition.longitudeI
				dstPosition.precisionBits = srcPosition.precisionBits
				dstPosition.satsInView = srcPosition.satsInView
				dstPosition.seqNo = srcPosition.seqNo
				dstPosition.snr = srcPosition.snr
				dstPosition.speed = srcPosition.speed
				dstPosition.time = srcPosition.time
				dstPosition.traceRoute = dst
			}
		}
	}

	nonisolated static func importPaxCounters(from backupContext: NSManagedObjectContext, into liveContext: NSManagedObjectContext, nodesByNum: [Int64: NodeInfoEntity]) throws {
		let request = NSFetchRequest<PaxCounterEntity>(entityName: "PaxCounterEntity")
		let backupPax = try backupContext.fetch(request)
		for src in backupPax {
			let dst = PaxCounterEntity(context: liveContext)
			dst.ble = src.ble
			dst.time = src.time
			dst.uptime = src.uptime
			dst.wifi = src.wifi
			if let srcNode = src.paxNode, let liveNode = nodesByNum[srcNode.num] {
				dst.paxNode = liveNode
			}
		}
	}
}