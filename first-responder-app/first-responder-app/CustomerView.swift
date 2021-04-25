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
                HStack{
                    Text("Your Current Location").font(.title2).fontWeight(.light).padding(.vertical)
                    Spacer()
                }
                HStack{
                    Text("Latitude: \(coordinate.latitude)").font(.headline)
                    Spacer()
                }
                HStack{
                    Text("Longitude: \(coordinate.longitude)").font(.headline)
                }.padding(.bottom, 25)
                
            }.padding().font(.headline).background(LinearGradient(gradient: Gradient(colors: [Color("red-light"),Color("red-dark")]), startPoint: .top, endPoint: .bottom)).cornerRadius(10).padding().padding(.horizontal).foregroundColor(.white)
        }
    }
}

struct RedButton: View{
    @State var animate = false
    var body: some View {
        ZStack{
            Circle().fill(Color("red-light").opacity(0.25)).frame(width: 375, height: 400).scaleEffect(self.animate ? 1 : 0)
            Circle().fill(Color("red-light").opacity(0.35)).frame(width: 300, height: 350).scaleEffect(self.animate ? 1 : 0)
            Circle().fill(Color("red-light").opacity(0.45)).frame(width: 225, height: 250).scaleEffect(self.animate ? 1 : 0)
            Circle().fill(Color("red-light").opacity(1)).frame(width: 150, height: 150)
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
