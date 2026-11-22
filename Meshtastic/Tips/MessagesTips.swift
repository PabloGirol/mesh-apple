//
//  MessagesTips.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 9/15/23.
//
import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
import TipKit

@available(iOS 16.0, macOS 13.0, *)
struct MessagesTip: Tip {

   var id: String {
	   return "tip.messages"
   }
   var title: Text {
	   Text("Messages")
   }
   var message: Text? {
	   Text("Send channel broadcasts and direct messages. Long press any message for actions like copy, reply, tapback, and delivery details.")
   }
   var image: Image? {
	   Image(systemName: "bubble.left.and.bubble.right")
   }
   var options: [TipOption] {
	   Tips.IgnoresDisplayFrequency(true)
	   Tips.MaxDisplayCount(3)
   }
}
