#!/usr/bin/env python3
"""
Generate NSManagedObject subclasses for Core Data entities.

This script creates Swift files for all 51+ entities based on:
- SwiftData model definitions in Meshtastic/Model/ConfigModels.swift
- CoreDataMigrationService entity/property mappings
- SwiftData model definitions in Meshtastic/Model/
"""

import os
import re
from pathlib import Path

# Entity definitions extracted from SwiftData models (ConfigModels.swift) + CoreDataMigrationService
ENTITIES = {
    # Core entities
    "NodeInfoEntity": {
        "properties": [
            ("bleName", "String?", "Optional"),
            ("channel", "Int32", ""),
            ("id", "Int64", ""),
            ("lastHeard", "Date", ""),
            ("num", "Int64", ""),
            ("snr", "Float", ""),
        ],
        "relationships": [
            ("user", "UserEntity", "toOne", "inverse: userNode"),
            ("myInfo", "MyInfoEntity", "toOne", "inverse: myInfoNode"),
            ("channels", "ChannelEntity", "toMany", "inverse: myInfoChannel"),
            ("positions", "PositionEntity", "toMany", "inverse: nodePosition"),
            ("telemetry", "TelemetryEntity", "toMany", "inverse: nodeTelemetry"),
            ("bluetoothConfig", "BluetoothConfigEntity", "toOne", "inverse: bluetoothConfigNode"),
            ("cannedMessageConfig", "CannedMessageConfigEntity", "toOne", "inverse: cannedMessagesConfigNode"),
            ("deviceConfig", "DeviceConfigEntity", "toOne", "inverse: deviceConfigNode"),
            ("displayConfig", "DisplayConfigEntity", "toOne", "inverse: displayConfigNode"),
            ("externalNotificationConfig", "ExternalNotificationConfigEntity", "toOne", "inverse: externalNotificationConfigNode"),
            ("loRaConfig", "LoRaConfigEntity", "toOne", "inverse: loRaConfigNode"),
            ("mqttConfig", "MQTTConfigEntity", "toOne", "inverse: mqttConfigNode"),
            ("networkConfig", "NetworkConfigEntity", "toOne", "inverse: networkConfigNode"),
            ("positionConfig", "PositionConfigEntity", "toOne", "inverse: positionConfigNode"),
            ("rangeTestConfig", "RangeTestConfigEntity", "toOne", "inverse: rangeTestConfigNode"),
            ("serialConfig", "SerialConfigEntity", "toOne", "inverse: serialConfigNode"),
            ("telemetryConfig", "TelemetryConfigEntity", "toOne", "inverse: telemetryConfigNode"),
            ("ambientLightingConfig", "AmbientLightingConfigEntity", "toOne", "inverse: ambientLightingConfigNode"),
            ("audioConfig", "AudioConfigEntity", "toOne", "inverse: audioConfigNode"),
            ("detectionSensorConfig", "DetectionSensorConfigEntity", "toOne", "inverse: detectionSensorConfigNode"),
            ("meshBeaconConfig", "MeshBeaconConfigEntity", "toOne", "inverse: meshBeaconConfigNode"),
            ("paxCounterConfig", "PaxCounterConfigEntity", "toOne", "inverse: paxCounterConfigNode"),
            ("powerConfig", "PowerConfigEntity", "toOne", "inverse: powerConfigNode"),
            ("rtttlConfig", "RTTTLConfigEntity", "toOne", "inverse: rtttlConfigNode"),
            ("securityConfig", "SecurityConfigEntity", "toOne", "inverse: securityConfigNode"),
            ("storeForwardConfig", "StoreForwardConfigEntity", "toOne", "inverse: storeForwardConfigNode"),
            ("takConfig", "TAKConfigEntity", "toOne", "inverse: takConfigNode"),
            ("neighborInfoConfig", "NeighborInfoConfigEntity", "toOne", "inverse: neighborInfoConfigNode"),
            ("statusMessageConfig", "StatusMessageConfigEntity", "toOne", "inverse: statusMessageConfigNode"),
        ]
    },

    "UserEntity": {
        "properties": [
            ("hwModel", "String?", "Optional"),
            ("isLicensed", "Bool", ""),
            ("longName", "String?", "Optional"),
            ("num", "Int64", ""),
            ("shortName", "String?", "Optional"),
            ("userId", "String?", "Optional"),
        ],
        "relationships": [
            ("userNode", "NodeInfoEntity", "toOne", "inverse: user"),
            ("messagesFrom", "MessageEntity", "toMany", "inverse: fromUser"),
            ("messagesTo", "MessageEntity", "toMany", "inverse: toUser"),
        ]
    },

    "MyInfoEntity": {
        "properties": [
            ("bleName", "String?", "Optional"),
            ("minAppVersion", "Int32", ""),
            ("myNodeNum", "Int64", ""),
            ("peripheralId", "String?", "Optional"),
            ("rebootCount", "Int32", ""),
        ],
        "relationships": [
            ("myInfoNode", "NodeInfoEntity", "toOne", "inverse: myInfo"),
            ("channels", "ChannelEntity", "toMany", "inverse: myInfoChannel"),
        ]
    },

    "MessageEntity": {
        "properties": [
            ("ackError", "Int32", ""),
            ("ackSNR", "Float", ""),
            ("ackTimestamp", "Int32", ""),
            ("admin", "Bool", ""),
            ("adminDescription", "String?", "Optional"),
            ("channel", "Int32", ""),
            ("isEmoji", "Bool", ""),
            ("messageId", "Int64", ""),
            ("messagePayload", "String?", "Optional"),
            ("messageTimestamp", "Int32", ""),
            ("receivedACK", "Bool", ""),
            ("replyID", "Int64", ""),
            ("snr", "Float", ""),
        ],
        "relationships": [
            ("fromUser", "UserEntity", "toOne", "inverse: messagesFrom"),
            ("toUser", "UserEntity", "toOne", "inverse: messagesTo"),
        ]
    },

    "ChannelEntity": {
        "properties": [
            ("downlinkEnabled", "Bool", ""),
            ("id", "Int32", ""),
            ("index", "Int32", ""),
            ("name", "String?", "Optional"),
            ("psk", "Data?", "Optional"),
            ("role", "Int32", ""),
            ("uplinkEnabled", "Bool", ""),
        ],
        "relationships": [
            ("myInfoChannel", "MyInfoEntity", "toOne", "inverse: channels"),
        ]
    },

    "PositionEntity": {
        "properties": [
            ("altitude", "Int32", ""),
            ("heading", "Int32", ""),
            ("latitudeI", "Int32", ""),
            ("longitudeI", "Int32", ""),
            ("satsInView", "Int32", ""),
            ("seqNo", "Int32", ""),
            ("snr", "Float", ""),
            ("speed", "Int32", ""),
            ("time", "Date?", "Optional"),
        ],
        "relationships": [
            ("nodePosition", "NodeInfoEntity", "toOne", "inverse: positions"),
        ]
    },

    "TelemetryEntity": {
        "properties": [
            ("metricsType", "Int32", ""),
            ("time", "Date?", "Optional"),
            ("airUtilTx", "Float?", "Optional"),
            ("barometricPressure", "Float?", "Optional"),
            ("batteryLevel", "Int32?", "Optional"),
            ("channelUtilization", "Float?", "Optional"),
            ("current", "Float?", "Optional"),
            ("gasResistance", "Float?", "Optional"),
            ("relativeHumidity", "Float?", "Optional"),
            ("temperature", "Float?", "Optional"),
            ("voltage", "Float?", "Optional"),
        ],
        "relationships": [
            ("nodeTelemetry", "NodeInfoEntity", "toOne", "inverse: telemetry"),
        ]
    },

    # Config entities (from ConfigModels.swift)
    "BluetoothConfigEntity": {
        "properties": [
            ("deviceLoggingEnabled", "Bool", ""),
            ("enabled", "Bool", ""),
            ("fixedPin", "Int32", ""),
            ("mode", "Int32", ""),
        ],
        "relationships": [
            ("bluetoothConfigNode", "NodeInfoEntity", "toOne", "inverse: bluetoothConfig"),
        ]
    },

    "CannedMessageConfigEntity": {
        "properties": [
            ("enabled", "Bool", ""),
            ("inputbrokerEventCcw", "Int32", ""),
            ("inputbrokerEventCw", "Int32", ""),
            ("inputbrokerEventPress", "Int32", ""),
            ("inputbrokerPinA", "Int32", ""),
            ("inputbrokerPinB", "Int32", ""),
            ("inputbrokerPinPress", "Int32", ""),
            ("messages", "String?", "Optional"),
            ("rotary1Enabled", "Bool", ""),
            ("sendBell", "Bool", ""),
            ("updown1Enabled", "Bool", ""),
        ],
        "relationships": [
            ("cannedMessagesConfigNode", "NodeInfoEntity", "toOne", "inverse: cannedMessageConfig"),
        ]
    },

    "DetectionSensorConfigEntity": {
        "properties": [
            ("enabled", "Bool", ""),
            ("minimumBroadcastSecs", "Int32", ""),
            ("monitorPin", "Int32", ""),
            ("name", "String?", "Optional"),
            ("sendBell", "Bool", ""),
            ("stateBroadcastSecs", "Int32", ""),
            ("triggerType", "Int32", ""),
            ("usePullup", "Bool", ""),
        ],
        "relationships": [
            ("detectionSensorConfigNode", "NodeInfoEntity", "toOne", "inverse: detectionSensorConfig"),
        ]
    },

    "DeviceConfigEntity": {
        "properties": [
            ("buttonGpio", "Int32", ""),
            ("buzzerGpio", "Int32", ""),
            ("debugLogEnabled", "Bool", ""),
            ("disableTripleClick", "Bool", ""),
            ("doubleTapAsButtonPress", "Bool", ""),
            ("isManaged", "Bool", ""),
            ("ledHeartbeatEnabled", "Bool", ""),
            ("nodeInfoBroadcastSecs", "Int32", ""),
            ("rebroadcastMode", "Int32", ""),
            ("role", "Int32", ""),
            ("serialEnabled", "Bool", ""),
            ("tripleClickAsAdHocPing", "Bool", ""),
            ("tzdef", "String?", "Optional"),
        ],
        "relationships": [
            ("deviceConfigNode", "NodeInfoEntity", "toOne", "inverse: deviceConfig"),
        ]
    },

    "DisplayConfigEntity": {
        "properties": [
            ("compassNorthTop", "Bool", ""),
            ("compassOrientation", "Int32", ""),
            ("displayMode", "Int32", ""),
            ("flipScreen", "Bool", ""),
            ("headingBold", "Bool", ""),
            ("oledType", "Int32", ""),
            ("screenCarouselInterval", "Int32", ""),
            ("screenOnSeconds", "Int32", ""),
            ("units", "Int32", ""),
            ("use12HClock", "Bool", ""),
            ("wakeOnTapOrMotion", "Bool", ""),
        ],
        "relationships": [
            ("displayConfigNode", "NodeInfoEntity", "toOne", "inverse: displayConfig"),
        ]
    },

    "ExternalNotificationConfigEntity": {
        "properties": [
            ("active", "Bool", ""),
            ("alertBell", "Bool", ""),
            ("alertBellBuzzer", "Bool", ""),
            ("alertBellVibra", "Bool", ""),
            ("alertMessage", "Bool", ""),
            ("alertMessageBuzzer", "Bool", ""),
            ("alertMessageVibra", "Bool", ""),
            ("enabled", "Bool", ""),
            ("nagTimeout", "Int32", ""),
            ("output", "Int32", ""),
            ("outputBuzzer", "Int32", ""),
            ("outputMilliseconds", "Int32", ""),
            ("outputVibra", "Int32", ""),
            ("useI2SAsBuzzer", "Bool", ""),
            ("usePWM", "Bool", ""),
        ],
        "relationships": [
            ("externalNotificationConfigNode", "NodeInfoEntity", "toOne", "inverse: externalNotificationConfig"),
        ]
    },

    "LoRaConfigEntity": {
        "properties": [
            ("bandwidth", "Int32", ""),
            ("channelNum", "Int32", ""),
            ("codingRate", "Int32", ""),
            ("frequencyOffset", "Float", ""),
            ("hopLimit", "Int32", ""),
            ("ignoreMqtt", "Bool", ""),
            ("modemPreset", "Int32", ""),
            ("okToMqtt", "Bool", ""),
            ("overrideDutyCycle", "Bool", ""),
            ("paFanDisabled", "Bool", ""),
            ("overrideFrequency", "Float", ""),
            ("regionCode", "Int32", ""),
            ("spreadFactor", "Int32", ""),
            ("sx126xRxBoostedGain", "Bool", ""),
            ("txEnabled", "Bool", ""),
            ("txPower", "Int32", ""),
            ("usePreset", "Bool", ""),
        ],
        "relationships": [
            ("loRaConfigNode", "NodeInfoEntity", "toOne", "inverse: loRaConfig"),
        ]
    },

    "MQTTConfigEntity": {
        "properties": [
            ("address", "String?", "Optional"),
            ("enabled", "Bool", ""),
            ("encryptionEnabled", "Bool", ""),
            ("jsonEnabled", "Bool", ""),
            ("mapPositionPrecision", "Int32", ""),
            ("mapPublishIntervalSecs", "Int32", ""),
            ("mapReportingEnabled", "Bool", ""),
            ("mapReportingShouldReportLocation", "Bool", ""),
            ("password", "String?", "Optional"),
            ("proxyToClientEnabled", "Bool", ""),
            ("root", "String?", "Optional"),
            ("tlsEnabled", "Bool", ""),
            ("username", "String?", "Optional"),
        ],
        "relationships": [
            ("mqttConfigNode", "NodeInfoEntity", "toOne", "inverse: mqttConfig"),
        ]
    },

    "NetworkConfigEntity": {
        "properties": [
            ("addressMode", "Int32", ""),
            ("dns", "Int32", ""),
            ("enabledProtocols", "Int32", ""),
            ("ethEnabled", "Bool", ""),
            ("gateway", "Int32", ""),
            ("ip", "Int32", ""),
            ("ntpServer", "String?", "Optional"),
            ("rsyslogServer", "String?", "Optional"),
            ("subnet", "Int32", ""),
            ("wifiEnabled", "Bool", ""),
            ("wifiMode", "Int32", ""),
            ("wifiPsk", "String?", "Optional"),
            ("wifiSsid", "String?", "Optional"),
        ],
        "relationships": [
            ("networkConfigNode", "NodeInfoEntity", "toOne", "inverse: networkConfig"),
        ]
    },

    "NeighborInfoConfigEntity": {
        "properties": [
            ("enabled", "Bool", ""),
            ("transmitOverLora", "Bool", ""),
            ("updateInterval", "Int32", ""),
        ],
        "relationships": [
            ("neighborInfoConfigNode", "NodeInfoEntity", "toOne", "inverse: neighborInfoConfig"),
        ]
    },

    "PaxCounterConfigEntity": {
        "properties": [
            ("bleThreshold", "Int32", ""),
            ("enabled", "Bool", ""),
            ("updateInterval", "Int32", ""),
            ("wifiThreshold", "Int32", ""),
        ],
        "relationships": [
            ("paxCounterConfigNode", "NodeInfoEntity", "toOne", "inverse: paxCounterConfig"),
        ]
    },

    "PositionConfigEntity": {
        "properties": [
            ("broadcastSmartMinimumDistance", "Int32", ""),
            ("broadcastSmartMinimumIntervalSecs", "Int32", ""),
            ("deviceGpsEnabled", "Bool", ""),
            ("fixedPosition", "Bool", ""),
            ("gpsAttemptTime", "Int32", ""),
            ("gpsEnGpio", "Int32", ""),
            ("gpsMode", "Int32", ""),
            ("gpsUpdateInterval", "Int32", ""),
            ("positionBroadcastSeconds", "Int32", ""),
            ("positionFlags", "Int32", ""),
            ("rxGpio", "Int32", ""),
            ("smartPositionEnabled", "Bool", ""),
            ("txGpio", "Int32", ""),
        ],
        "relationships": [
            ("positionConfigNode", "NodeInfoEntity", "toOne", "inverse: positionConfig"),
        ]
    },

    "PowerConfigEntity": {
        "properties": [
            ("adcMultiplierOverride", "Float", ""),
            ("deviceBatteryInaAddress", "Int32", ""),
            ("isPowerSaving", "Bool", ""),
            ("lsSecs", "Int32", ""),
            ("minWakeSecs", "Int32", ""),
            ("onBatteryShutdownAfterSecs", "Int32", ""),
            ("waitBluetoothSecs", "Int32", ""),
        ],
        "relationships": [
            ("powerConfigNode", "NodeInfoEntity", "toOne", "inverse: powerConfig"),
        ]
    },

    "RangeTestConfigEntity": {
        "properties": [
            ("enabled", "Bool", ""),
            ("save", "Bool", ""),
            ("sender", "Int32", ""),
        ],
        "relationships": [
            ("rangeTestConfigNode", "NodeInfoEntity", "toOne", "inverse: rangeTestConfig"),
        ]
    },

    "RTTTLConfigEntity": {
        "properties": [
            ("ringtone", "String?", "Optional"),
        ],
        "relationships": [
            ("rtttlConfigNode", "NodeInfoEntity", "toOne", "inverse: rtttlConfig"),
        ]
    },

    "SecurityConfigEntity": {
        "properties": [
            ("adminChannelEnabled", "Bool", ""),
            ("adminKey", "Data?", "Optional"),
            ("adminKey2", "Data?", "Optional"),
            ("adminKey3", "Data?", "Optional"),
            ("bluetoothLoggingEnabled", "Bool", ""),
            ("debugLogApiEnabled", "Bool", ""),
            ("isManaged", "Bool", ""),
            ("packetSignaturePolicy", "Int32", ""),
            ("privateKey", "Data?", "Optional"),
            ("publicKey", "Data?", "Optional"),
            ("serialEnabled", "Bool", ""),
        ],
        "relationships": [
            ("securityConfigNode", "NodeInfoEntity", "toOne", "inverse: securityConfig"),
        ]
    },

    "SerialConfigEntity": {
        "properties": [
            ("baudRate", "Int32", ""),
            ("echo", "Bool", ""),
            ("enabled", "Bool", ""),
            ("mode", "Int32", ""),
            ("overrideConsoleSerialPort", "Bool", ""),
            ("rxd", "Int32", ""),
            ("timeout", "Int32", ""),
            ("txd", "Int32", ""),
        ],
        "relationships": [
            ("serialConfigNode", "NodeInfoEntity", "toOne", "inverse: serialConfig"),
        ]
    },

    "StoreForwardConfigEntity": {
        "properties": [
            ("enabled", "Bool", ""),
            ("heartbeat", "Bool", ""),
            ("historyReturnMax", "Int32", ""),
            ("historyReturnWindow", "Int32", ""),
            ("isRouter", "Bool", ""),
            ("lastHeartbeat", "Date?", "Optional"),
            ("lastRequest", "Int32", ""),
            ("records", "Int32", ""),
        ],
        "relationships": [
            ("storeForwardConfigNode", "NodeInfoEntity", "toOne", "inverse: storeForwardConfig"),
        ]
    },

    "StatusMessageConfigEntity": {
        "properties": [
            ("nodeStatus", "String", ""),
        ],
        "relationships": [
            ("statusMessageConfigNode", "NodeInfoEntity", "toOne", "inverse: statusMessageConfig"),
        ]
    },

    "TAKConfigEntity": {
        "properties": [
            ("role", "Int32", ""),
            ("team", "Int32", ""),
        ],
        "relationships": [
            ("takConfigNode", "NodeInfoEntity", "toOne", "inverse: takConfig"),
        ]
    },

    "TelemetryConfigEntity": {
        "properties": [
            ("airQualityEnabled", "Bool", ""),
            ("airQualityInterval", "Int32", ""),
            ("deviceTelemetryEnabled", "Bool", ""),
            ("deviceUpdateInterval", "Int32", ""),
            ("environmentDisplayFahrenheit", "Bool", ""),
            ("environmentMeasurementEnabled", "Bool", ""),
            ("environmentScreenEnabled", "Bool", ""),
            ("environmentUpdateInterval", "Int32", ""),
            ("powerMeasurementEnabled", "Bool", ""),
            ("powerScreenEnabled", "Bool", ""),
            ("powerUpdateInterval", "Int32", ""),
        ],
        "relationships": [
            ("telemetryConfigNode", "NodeInfoEntity", "toOne", "inverse: telemetryConfig"),
        ]
    },

    "AmbientLightingConfigEntity": {
        "properties": [
            ("blue", "Int32", ""),
            ("current", "Int32", ""),
            ("green", "Int32", ""),
            ("ledState", "Bool", ""),
            ("red", "Int32", ""),
        ],
        "relationships": [
            ("ambientLightingConfigNode", "NodeInfoEntity", "toOne", "inverse: ambientLightingConfig"),
        ]
    },

    "AudioConfigEntity": {
        "properties": [
            ("codec2Enabled", "Bool", ""),
            ("pttPin", "Int32", ""),
            ("bitrate", "Int32", ""),
            ("i2sWs", "Int32", ""),
            ("i2sSd", "Int32", ""),
            ("i2sDin", "Int32", ""),
            ("i2sSck", "Int32", ""),
        ],
        "relationships": [
            ("audioConfigNode", "NodeInfoEntity", "toOne", "inverse: audioConfig"),
        ]
    },

    "MeshBeaconConfigEntity": {
        "properties": [
            ("flags", "Int32", ""),
            ("broadcastMessage", "String", ""),
            ("broadcastOfferChannelName", "String", ""),
            ("broadcastOfferChannelPSK", "Data", ""),
            ("broadcastOfferRegion", "Int32", ""),
            ("broadcastOfferPreset", "Int32", ""),
            ("broadcastOfferFrequencySlot", "Int32", ""),
            ("broadcastOnChannelName", "String", ""),
            ("broadcastOnChannelPSK", "Data", ""),
            ("broadcastOnRegion", "Int32", ""),
            ("broadcastOnPreset", "Int32", ""),
            ("broadcastIntervalSecs", "Int32", ""),
            ("broadcastSendAsNode", "Int64", ""),
        ],
        "relationships": [
            ("broadcastTargets", "BroadcastTargetEntity", "toMany", "inverse: meshBeaconConfig"),
            ("meshBeaconConfigNode", "NodeInfoEntity", "toOne", "inverse: meshBeaconConfig"),
        ]
    },

    "BroadcastTargetEntity": {
        "properties": [
            ("preset", "Int32", ""),
            ("region", "Int32", ""),
            ("channelIndex", "Int32", ""),
            ("frequencySlot", "Int32", ""),
        ],
        "relationships": [
            ("meshBeaconConfig", "MeshBeaconConfigEntity", "toOne", "inverse: broadcastTargets"),
        ]
    },

    # Device hardware
    "DeviceHardwareEntity": {
        "properties": [
            ("hwModel", "String", ""),
            ("variant", "String?", "Optional"),
        ],
        "relationships": [
            ("tags", "DeviceHardwareTagEntity", "toMany", "inverse: device"),
            ("images", "DeviceHardwareImageEntity", "toMany", "inverse: device"),
        ]
    },

    "DeviceHardwareImageEntity": {
        "properties": [
            ("imageData", "Data", ""),
            ("isDefault", "Bool", ""),
        ],
        "relationships": [
            ("device", "DeviceHardwareEntity", "toOne", "inverse: images"),
        ]
    },

    "DeviceHardwareTagEntity": {
        "properties": [
            ("tag", "String", ""),
        ],
        "relationships": [
            ("device", "DeviceHardwareEntity", "toOne", "inverse: tags"),
        ]
    },

    "DeviceLinkEntity": {
        "properties": [
            ("deviceId", "String", ""),
            ("deviceName", "String", ""),
            ("lastConnected", "Date", ""),
        ],
        "relationships": []
    },

    "FirmwareReleaseEntity": {
        "properties": [
            ("channel", "String", ""),
            ("version", "String", ""),
            ("releaseDate", "Date", ""),
            ("changelog", "String?", "Optional"),
            ("downloadURL", "String", ""),
            ("hardwareModel", "String", ""),
            ("minAppVersion", "Int32", ""),
            ("signature", "String?", "Optional"),
        ],
        "relationships": []
    },

    "EventFirmwareEntity": {
        "properties": [
            ("eventId", "String", ""),
            ("firmwareVersion", "String", ""),
            ("hardwareModel", "String", ""),
            ("timestamp", "Date", ""),
        ],
        "relationships": []
    },

    # Discovery
    "DiscoverySessionEntity": {
        "properties": [
            ("id", "UUID", ""),
            ("startTime", "Date", ""),
            ("endTime", "Date?", "Optional"),
            ("selectedPresets", "Data", ""),  # JSON encoded
            ("dwellDuration", "Int32", ""),
            ("completed", "Bool", ""),
        ],
        "relationships": [
            ("presetResults", "DiscoveryPresetResultEntity", "toMany", "inverse: session"),
            ("discoveredNodes", "DiscoveredNodeEntity", "toMany", "inverse: session"),
            ("discoveredBeacons", "DiscoveredBeaconEntity", "toMany", "inverse: session"),
        ]
    },

    "DiscoveryPresetResultEntity": {
        "properties": [
            ("presetIndex", "Int32", ""),
            ("presetName", "String", ""),
            ("nodesHeard", "Int32", ""),
            ("snrSum", "Float", ""),
            ("snrCount", "Int32", ""),
        ],
        "relationships": [
            ("session", "DiscoverySessionEntity", "toOne", "inverse: presetResults"),
        ]
    },

    "DiscoveredNodeEntity": {
        "properties": [
            ("nodeNum", "Int64", ""),
            ("snr", "Float", ""),
            ("lastHeard", "Date", ""),
            ("hopsAway", "Int32", ""),
        ],
        "relationships": [
            ("session", "DiscoverySessionEntity", "toOne", "inverse: discoveredNodes"),
        ]
    },

    "DiscoveredBeaconEntity": {
        "properties": [
            ("channelIndex", "Int32", ""),
            ("nodeNum", "Int64", ""),
            ("snr", "Float", ""),
            ("lastHeard", "Date", ""),
            ("hopLimit", "Int32", ""),
            ("payload", "Data?", "Optional"),
        ],
        "relationships": [
            ("session", "DiscoverySessionEntity", "toOne", "inverse: discoveredBeacons"),
        ]
    },

    # Additional entities from SwiftData schema
    "WaypointEntity": {
        "properties": [
            ("id", "UUID", ""),
            ("name", "String", ""),
            ("descriptionText", "String?", "Optional"),
            ("latitudeI", "Int32", ""),
            ("longitudeI", "Int32", ""),
            ("altitude", "Int32", ""),
            ("createdAt", "Date", ""),
            ("updatedAt", "Date", ""),
            ("isShared", "Bool", ""),
        ],
        "relationships": []
    },

    "RouteEntity": {
        "properties": [
            ("id", "UUID", ""),
            ("name", "String", ""),
            ("createdAt", "Date", ""),
            ("updatedAt", "Date", ""),
        ],
        "relationships": [
            ("locations", "LocationEntity", "toMany", "inverse: route"),
        ]
    },

    "LocationEntity": {
        "properties": [
            ("id", "UUID", ""),
            ("latitudeI", "Int32", ""),
            ("longitudeI", "Int32", ""),
            ("altitude", "Int32", ""),
            ("timestamp", "Date", ""),
            ("sequence", "Int32", ""),
        ],
        "relationships": [
            ("route", "RouteEntity", "toOne", "inverse: locations"),
        ]
    },

    "NeighborLinkEntity": {
        "properties": [
            ("id", "UUID", ""),
            ("localNodeNum", "Int64", ""),
            ("neighborNodeNum", "Int64", ""),
            ("snr", "Float", ""),
            ("channel", "Int32", ""),
            ("lastHeard", "Date", ""),
        ],
        "relationships": []
    },

    "PaxCounterEntity": {
        "properties": [
            ("time", "Date", ""),
            ("count", "Int32", ""),
            ("snr", "Float", ""),
        ],
        "relationships": []
    },

    "TraceRouteEntity": {
        "properties": [
            ("id", "UUID", ""),
            ("targetNodeNum", "Int64", ""),
            ("startTime", "Date", ""),
            ("completed", "Bool", ""),
        ],
        "relationships": [
            ("hops", "TraceRouteHopEntity", "toMany", "inverse: traceRoute"),
        ]
    },

    "TraceRouteHopEntity": {
        "properties": [
            ("hopIndex", "Int32", ""),
            ("nodeNum", "Int64", ""),
            ("snrTowards", "Float", ""),
            ("snrBack", "Float", ""),
        ],
        "relationships": [
            ("traceRoute", "TraceRouteEntity", "toOne", "inverse: hops"),
        ]
    },

    "TraceRouteNodePositionEntity": {
        "properties": [
            ("nodeNum", "Int64", ""),
            ("latitudeI", "Int32", ""),
            ("longitudeI", "Int32", ""),
        ],
        "relationships": []
    },

    "DeviceMetadataEntity": {
        "properties": [
            ("deviceId", "String", ""),
            ("key", "String", ""),
            ("value", "String", ""),
        ],
        "relationships": []
    },
}

# Template for NSManagedObject subclass
TEMPLATE = '''//
//
//
import CoreData
import Foundation

@objc({entity_name})
public class {entity_name}: NSManagedObject {{

}}

extension {entity_name} {{
{property_declarations}
}}

extension {entity_name}: CoreDataEntity {{
    public static var entityName: String {{ "{entity_name}" }}
}}
'''

def generate_entity(entity_name, definition):
    props = definition.get("properties", [])
    rels = definition.get("relationships", [])

    decls = []
    for prop_name, prop_type, prop_opt in props:
        optional = "?" if prop_opt == "Optional" else ""
        decls.append(f"    @NSManaged public var {prop_name}: {prop_type}{optional}")

    for rel_name, rel_type, rel_card, rel_inverse in rels:
        optional = "?" if rel_card == "toOne" else ""
        if rel_card == "toMany":
            decls.append(f"    @NSManaged public var {rel_name}: NSSet{optional}")
        else:
            decls.append(f"    @NSManaged public var {rel_name}: {rel_type}{optional}")

    # Add toMany helpers
    for rel_name, rel_type, rel_card, rel_inverse in rels:
        if rel_card == "toMany":
            decls.append(f"""
    @objc(add{rel_name.capitalize()}Object:)
    @NSManaged public func addTo{rel_name.capitalize()}(_ value: {rel_type})

    @objc(remove{rel_name.capitalize()}Object:)
    @NSManaged public func removeFrom{rel_name.capitalize()}(_ value: {rel_type})

    @objc(add{rel_name.capitalize()}:)
    @NSManaged public func addTo{rel_name.capitalize()}(_ values: NSSet)

    @objc(remove{rel_name.capitalize()}:)
    @NSManaged public func removeFrom{rel_name.capitalize()}(_ values: NSSet)
""")

    property_decls = "\n".join(decls)

    return TEMPLATE.format(
        entity_name=entity_name,
        property_declarations=property_decls
    )

def main():
    output_dir = Path("Meshtastic/Model/CoreData")
    output_dir.mkdir(parents=True, exist_ok=True)

    for entity_name, definition in ENTITIES.items():
        content = generate_entity(entity_name, definition)
        file_path = output_dir / f"{entity_name}.swift"
        file_path.write_text(content)
        print(f"Generated: {file_path}")

    print(f"\nDone! Generated {len(ENTITIES)} entity files in {output_dir}")

if __name__ == "__main__":
    main()