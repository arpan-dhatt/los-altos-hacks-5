//
//  CustomerView.swift
//  first-responder-app
//
//  Created by user175936 on 4/24/21.
//

import SwiftUI
import MapKit

struct CustomerView: View {
    @ObservedObject private var locationManager = LocationManager()
    
    var body: some View {
        let coordinate = self.locationManager.location != nil ? self.locationManager.location!.coordinate : CLLocationCoordinate2D()
        
        VStack(alignment: .leading){
            Text("You Are Connected To The Disaster Duck Network").font(.title).bold().padding(.leading)
            RedButton()
            VStack(alignment: .leading){
                Text("Your Current Location").padding(.vertical).font(.title3)
                Text("Latitude: \(coordinate.latitude)")
                Text("Longitude: \(coordinate.longitude)")
                
            }.padding().font(.headline)
        }
    }
}

struct RedButton: View{
    @State var animate = false
    var body: some View {
        ZStack{
            Circle().fill(Color.red.opacity(0.25)).frame(width: 375, height: 400).scaleEffect(self.animate ? 1 : 0)
            Circle().fill(Color.red.opacity(0.35)).frame(width: 300, height: 350).scaleEffect(self.animate ? 1 : 0)
            Circle().fill(Color.red.opacity(0.45)).frame(width: 225, height: 250).scaleEffect(self.animate ? 1 : 0)
            Circle().fill(Color.red.opacity(1)).frame(width: 150, height: 150)
            Text("S.O.S").font(.title).foregroundColor(.white).fontWeight(.light)
        }.onTapGesture {
            self.animate.toggle()
        }.animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: true))
    }
}

struct CustomerView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerView()
    }
}
