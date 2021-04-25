//
//  ResponderView.swift
//  first-responder-app
//
//  Created by user175936 on 4/24/21.
//
import SwiftUI
import  MapKit

struct ResponderView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State var markers: [Marker] = [Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: 56.948889, longitude: 24.106389), tint: .red))]
    
    @State private var coordinateRegion = MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: 56.948889, longitude: 24.106389),
          span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @Namespace var animation
    
    var body: some View {
        ZStack{
            NavigationView{
                VStack(alignment: .leading){
                    Divider()
                    ScrollView{
                    
                    
                        VStack{
                            HStack{
                                Text("Pinned Emergencies:").font(.title2).fontWeight(.light)
                                Spacer()
                            }
                            
                            ForEach(viewModel.savedEmergencies, id: \.id){ emergency in
                                emergencySavedCardView(emergency: emergency).matchedGeometryEffect(id: emergency.name, in: animation)
                            }
                            
                            Map(coordinateRegion: $coordinateRegion, annotationItems: viewModel.savedMarkers){
                                marker in marker.location
                            }.frame(minHeight: 150, maxHeight: 150).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))

                        }.padding(.top)
                        VStack{
                            HStack{
                                Text("All Emergencies:").font(.title2).fontWeight(.light)
                                Spacer()
                            }
                            
                            ForEach(viewModel.activeEmergencies, id: \.id){ emergency in
                                emergencyCardView(emergency: emergency).matchedGeometryEffect(id: emergency.name, in: animation)
                            }
                            
                            Map(coordinateRegion: $coordinateRegion, annotationItems: viewModel.activeMarkers){
                                marker in marker.location
                            }.frame(minHeight: 150, maxHeight: 150).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                            
                        }.padding(.top)
                    }.padding()
                }.navigationTitle("Current Emergencies")
            }
        }
    }
}

struct emergencyCardView: View {
    @EnvironmentObject var viewModel: ViewModel
    var emergency: emergency
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "flame.fill").font(.title)
                Spacer()
                Image(systemName: "plus.square.fill.on.square.fill").font(.title).onTapGesture {
                    withAnimation{
                        viewModel.addSaved(e: emergency)
                    }
                }
            }
            HStack(alignment: .top){
            VStack(alignment: .leading){
                Text(emergency.name).font(.title2).fontWeight(.bold).padding(.bottom)
                Text(String(format: "Location: [ %.2f , %.2f ]", emergency.latitude, emergency.longitude)).font(.headline).fontWeight(.light)
            }.padding(.top)
            Spacer()
            VStack(alignment: .leading){
                if emergency.activated{
                    Text("Active").font(.title2).fontWeight(.light)
                }
                else{
                    Text("Not Active").font(.title2).fontWeight(.light)
                }
                
            }.padding(.top)
        }
        }.padding().background(Color.black).cornerRadius(10.0).foregroundColor(.white).padding(.vertical).padding(.horizontal, 5)
    }
}

struct emergencySavedCardView: View {
    @EnvironmentObject var viewModel: ViewModel
    var emergency: emergency
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "flame.fill").font(.title)
                Spacer()
                Image(systemName: "x.circle.fill").font(.title).onTapGesture {
                    withAnimation{
                        viewModel.removeSaved(e: emergency)
                    }
                }
            }
            HStack(alignment: .top){
            VStack(alignment: .leading){
                Text(emergency.name).font(.title2).fontWeight(.bold).padding(.bottom)
                Text(String(format: "Location: [ %.2f , %.2f ]", emergency.latitude, emergency.longitude)).font(.headline).fontWeight(.light)
            }.padding(.top)
            Spacer()
            VStack(alignment: .leading){
                if emergency.activated{
                    Text("Active").font(.title2).fontWeight(.light)
                }
                else{
                    Text("Not Active").font(.title2).fontWeight(.light)
                }
                
            }.padding(.top)
        }
        }.padding().background(Color.black).cornerRadius(10.0).foregroundColor(.white).padding(.vertical).padding(.horizontal, 5)
    }
}

struct ResponderView_Previews: PreviewProvider {
    static var previews: some View {
        ResponderView().environmentObject(ViewModel())
    }
}
