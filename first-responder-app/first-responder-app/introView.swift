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
            
            Circle().fill(Color("yellow")).frame(width: 100, height: 100).padding(.top, -243).padding(.leading, -224)
            Circle().fill(Color("yellow")).frame(width: 125, height: 125).padding(.top, -320).padding(.leading, 320)
            Circle().fill(Color("yellow")).frame(width: 75, height: 75).padding(.top, -400).padding(.leading, -150)
            Circle().fill(Color("yellow")).frame(width: 100, height: 100).padding(.top, 750).padding(.leading, 200)
            Circle().fill(Color("yellow")).frame(width: 50, height: 50).padding(.top, 650).padding(.leading, -125)
            
            VStack(alignment: .center){
                HStack{
                    Spacer()
                    Text("Welcome To Disaster Duck").font(.title)
                    Spacer()
                }.padding(.top, 100)
                Text("I Am").font(.largeTitle).bold().padding()
                Spacer()
                VStack{
                    HStack{
                        Spacer()
                        Text("A First Responder").font(.title).fontWeight(.light)
                        Spacer()
                    }.padding().padding(.vertical,50)
                }.background(LinearGradient(gradient: Gradient(colors: [Color("blue-light"),Color("blue-dark")]), startPoint: .top, endPoint: .bottom)).cornerRadius(10).padding().padding(.horizontal).foregroundColor(.white).onTapGesture {
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
                }.background(LinearGradient(gradient: Gradient(colors: [Color("red-light"),Color("red-dark")]), startPoint: .top, endPoint: .bottom)).cornerRadius(10).padding().padding(.horizontal).foregroundColor(.white).onTapGesture {
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

