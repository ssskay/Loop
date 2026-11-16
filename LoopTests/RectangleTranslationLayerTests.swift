//
//  RectangleTranslationLayerTests.swift
//  LoopTests
//
//  Created by ssskay on 2026-11-16.
//

import CoreGraphics
import Foundation
@testable import Loop
import Testing

struct RectangleTranslationLayerTests {
    /// Builds the JSON that Rectangle writes when exporting its config, limited to the `shortcuts` section
    /// (the only part Loop reads). Rectangle keys each shortcut by its action name.
    /// - Parameter shortcuts: Rectangle action names mapped to the key code bound to them.
    /// - Returns: the encoded config file contents.
    private func rectangleConfig(_ shortcuts: [String: CGKeyCode]) throws -> Data {
        // Control + Option, the modifiers Rectangle uses for its default shortcuts.
        let modifierFlags = 786_432

        let entries = shortcuts.mapValues { keyCode in
            ["keyCode": Int(keyCode), "modifierFlags": modifierFlags]
        }

        return try JSONSerialization.data(withJSONObject: [
            "bundleId": "com.knollsoft.Rectangle",
            "shortcuts": entries
        ])
    }

    /// Rectangle binds all four corners by default (⌃⌥U, ⌃⌥I, ⌃⌥J, ⌃⌥K), so every corner should survive an import.
    @Test func allFourCornersAreImported() throws {
        let data = try rectangleConfig([
            "topLeft": .kVK_ANSI_U,
            "topRight": .kVK_ANSI_I,
            "bottomLeft": .kVK_ANSI_J,
            "bottomRight": .kVK_ANSI_K
        ])

        let imported = try RectangleTranslationLayer.importKeybinds(from: data)
        let directions = Set(imported.map(\.direction))

        #expect(directions == [.topLeftQuarter, .topRightQuarter, .bottomLeftQuarter, .bottomRightQuarter])
    }

    /// The bottom-left shortcut should keep the key it was bound to in Rectangle.
    @Test func bottomLeftKeepsItsKey() throws {
        let data = try rectangleConfig(["bottomLeft": .kVK_ANSI_J])

        let imported = try RectangleTranslationLayer.importKeybinds(from: data)

        #expect(imported.count == 1)
        #expect(imported.first?.direction == .bottomLeftQuarter)
        #expect(imported.first?.keybind == [.kVK_ANSI_J])
    }
}
