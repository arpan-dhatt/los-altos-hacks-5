//
//  introView.swift
//  first-responder-app
//
//  Created by user175936 on 4/24/21.
//

import SwiftUI

struct introView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                
                Text("I Am").font(.largeTitle).bold().padding()
                Spacer()
                VStack{
                    HStack{
                        Spacer()
                        Text("A First Responder").font(.title).fontWeight(.light)
                        Spacer()
                    }.padding().padding(.vertical,50)
                }.background(Color.pink).cornerRadius(10).padding(.vertical).foregroundColor(.white).onTapGesture {
                    withAnimation{
                        viewModel.page = "responder"
                    }
                }
                
                VStack{
                    HStack{
                        Spacer()
                        Text("In Need Of Help").font(.title).fontWeight(.light)
                        Spacer()
                    }.padding().padding(.vertical,50)
                }.background(Color.blue).cornerRadius(10).padding(.vertical).foregroundColor(.white).onTapGesture {
                    withAnimation{
                        viewModel.page = "customer"
                    }
                }
                
                Spacer()
            }.padding()
        }
    }
}

struct introView_Previews: PreviewProvider {
    static var previews: some View {
        introView().environmentObject(ViewModel())
    }
}

