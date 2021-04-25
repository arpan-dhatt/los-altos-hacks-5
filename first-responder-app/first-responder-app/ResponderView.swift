//
//  ResponderView.swift
//  first-responder-app
//
//  Created by user175936 on 4/24/21.
//

import SwiftUI

struct ResponderView: View {
    @EnvironmentObject var viewModel: ViewModel
    
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
                                emergencySavedCardView(emergency: emergency)
                            }

                        }.padding(.top)
                        VStack{
                            HStack{
                                Text("All Emergencies:").font(.title2).fontWeight(.light)
                                Spacer()
                            }
                            
                            ForEach(viewModel.activeEmergencies, id: \.id){ emergency in
                                emergencyCardView(emergency: emergency)
                            }
                            
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
                Text(String(format: "Location: [ %.2f , \(emergency.longitude) ]", emergency.latitude)).font(.headline).fontWeight(.light)
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
                Text(String(format: "Location: [ %.2f , \(emergency.longitude) ]", emergency.latitude)).font(.headline).fontWeight(.light)
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
