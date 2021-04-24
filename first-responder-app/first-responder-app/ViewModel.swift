//
//  ViewModel.swift
//  first-responder-app
//
//  Created by user175936 on 4/24/21.
//

import SwiftUI

class ViewModel: ObservableObject {
    @Published var page = "intro"
    @Published var activeEmergencies: [emergency] = [emergency.init(name: "one", latitude: 1.0, longitude: 1.9, activated: true), emergency.init(name: "two", latitude: 1.3, longitude: 1.2, activated: true)]
    @Published var savedEmergencies: [emergency] = [emergency.init(name: "one", latitude: 1.0, longitude: 1.9, activated: true)]
}

struct emergency {
    var name: String
    var latitude: Double
    var longitude: Double
    var activated: Bool
    var id = UUID()
}
