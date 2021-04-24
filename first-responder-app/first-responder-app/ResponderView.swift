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
                                Text("My Saved Emergencies:").font(.title2).fontWeight(.light)
                                Spacer()
                            }
                            
                            ForEach(viewModel.savedEmergencies, id: \.id){ emergency in
                                emergencyCardView(emergency: emergency)
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
    var emergency: emergency
    var latitude = String(format: "%.2f", emergency.latitude)
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(emergency.name)
                Text("Location: [ \(format: "%.2f", emergency.latitude), \(emergency.longitude) ]" )
            }.padding()
            VStack(alignment: .leading){
                if emergency.activated{
                    Text("Active")
                }
                else{
                    Text("Not Active")
                }
            }.padding()
        }.background(Color.black).cornerRadius(10.0).foregroundColor(.white).padding()
    }
}

struct ResponderView_Previews: PreviewProvider {
    static var previews: some View {
        ResponderView().environmentObject(ViewModel())
    }
}
