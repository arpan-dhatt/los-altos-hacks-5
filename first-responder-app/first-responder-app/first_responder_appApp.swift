//
//  first_responder_appApp.swift
//  first-responder-app
//
//  Created by Arpan Dhatt on 4/24/21.
//

import SwiftUI

@main
struct first_responder_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ViewModel())
        }
    }
}
