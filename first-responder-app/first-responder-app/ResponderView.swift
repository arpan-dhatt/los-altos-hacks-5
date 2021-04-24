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
                                Text(emergency.name).padding()
                            }

                        }.padding(.top)
                        VStack{
                            HStack{
                                Text("All Emergencies:").font(.title2).fontWeight(.light)
                                Spacer()
                            }
                            
                            ForEach(viewModel.activeEmergencies, id: \.id){ emergency in
                                Text(emergency.name).padding()
                            }
                            
                        }.padding(.top)
                    }.padding()
                }.navigationTitle("Current Emergencies")
            }
        }
    }
}

struct ResponderView_Previews: PreviewProvider {
    static var previews: some View {
        ResponderView().environmentObject(ViewModel())
    }
}
