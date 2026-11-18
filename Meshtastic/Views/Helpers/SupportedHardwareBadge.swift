//
//  SwiftUIView.swift
//  Meshtastic
//
//  Created by Jake Bordens on 12/10/25.
//

import SwiftUI
import CoreData

struct SupportedHardwareBadge: View {

    @FetchRequest var hardware: FetchedResults<DeviceHardwareEntity>
    @EnvironmentObject var meshtasticAPI: MeshtasticAPI

    init<T>(hwModelId: T) where T: BinaryInteger {
        let hwModel = Int64(hwModelId)
        _hardware = FetchRequest(
            entity: DeviceHardwareEntity.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \DeviceHardwareEntity.hwModelSlug, ascending: true)],
            predicate: NSPredicate(format: "hwModel == %lld", hwModel)
        )
    }

    init(platformioTarget: String) {
        _hardware = FetchRequest(
            entity: DeviceHardwareEntity.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \DeviceHardwareEntity.hwModelSlug, ascending: true)],
            predicate: NSPredicate(format: "platformioTarget == %@", platformioTarget)
        )
    }

    private var presentation: HardwareCatalogPresentation? {
        guard let hwModel = hardware.first?.hwModel else { return nil }
        return HardwareCatalogResolver.presentation(for: hwModel, in: Array(hardware))
    }

    var body: some View {
        if let activelySupported = presentation?.activelySupported {
            VStack {
                Image(systemName: activelySupported ? "checkmark.seal.fill" : "x.circle")
                    .font(.largeTitle)
                    .foregroundStyle(activelySupported ? .green : .red)
                Text( activelySupported ? "Supported" : "Unsupported")
                    .foregroundStyle(.gray)
                    .font(.caption2)
                    .fixedSize()
            }
        } else if meshtasticAPI.isLoadingDeviceList {
            // Still loading the database from the API
            VStack {
                ProgressView()
                Text("Loading")
                    .foregroundStyle(.gray)
                    .font(.caption2)
                    .fixedSize()
            }
        } else {
            // Can't find this hardware in the database
            VStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
                Text("Unknown")
                    .foregroundStyle(.gray)
                    .font(.caption2)
                    .fixedSize()
            }
        }
    }
}