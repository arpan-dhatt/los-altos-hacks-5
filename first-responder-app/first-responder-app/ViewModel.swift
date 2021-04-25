//
//  ViewModel.swift
//  first-responder-app
//
//  Created by user175936 on 4/24/21.
//
import SwiftUI
import MapKit

class ViewModel: ObservableObject {
    @Published var page = "intro"
    @State private var coordinateRegion = MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: 56.948889, longitude: 24.106389),
          span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    @Published var activeEmergencies: [emergency] = [emergency.init(name: "Demo Signal One", latitude: 56.948889, longitude: 24.106389, activated: true), emergency.init(name: "Demo Signal Two", latitude: 56.948883, longitude: 24.106383, activated: false)]
    @Published var activeMarkers: [Marker] = [Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: 56.948889, longitude: 24.106389), tint: .red)),Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: 56.948883, longitude: 24.106383), tint: .red))]
    
    
    @Published var savedEmergencies: [emergency] = [emergency.init(name: "Demo Signal One", latitude: 56.948889, longitude: 24.106389, activated: true)]
    @Published var savedMarkers: [Marker] = [Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: 56.948889, longitude: 24.106389), tint: .red))]
    
    func removeSaved(e: emergency) -> Void {
        for i in 0..<savedEmergencies.count {
            if ((savedEmergencies[i].name == e.name) && (savedEmergencies[i].latitude == e.latitude)) {
                activeMarkers.append(Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: e.latitude, longitude: e.latitude), tint: .red)))
                activeEmergencies.append(e)
                
                savedEmergencies.remove(at: i)
                savedMarkers.remove(at: i)
                break
            }
        }
    }
    
    func addSaved(e: emergency) -> Void{
        var notDuplicate = true
        for i in savedEmergencies {
            if i.name == e.name {
                notDuplicate = false
            }
        }
        if notDuplicate{
            savedEmergencies.append(e)
            savedMarkers.append(Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: e.latitude, longitude: e.latitude), tint: .red)))
            
            for i in 0..<activeEmergencies.count {
                if ((activeEmergencies[i].name == e.name) && (activeEmergencies[i].latitude == e.latitude)) {
                    activeEmergencies.remove(at: i)
                    activeMarkers.remove(at: i)
                }
            }
        }
    }
}

struct emergency {
    var name: String
    var latitude: Double
    var longitude: Double
    var activated: Bool
    var id = UUID()
}

struct Marker: Identifiable {
    let id = UUID()
    var location: MapMarker
}
