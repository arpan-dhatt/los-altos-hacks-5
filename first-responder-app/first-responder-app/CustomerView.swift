//
//  CustomerView.swift
//  first-responder-app
//
//  Created by user175936 on 4/24/21.
//

import SwiftUI

struct CustomerView: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("You Are Connected To The Disaster Duck Network").font(.title).bold().padding(.leading)
            RedButton()
            VStack{
                Text("Your Current Location:")
                
            }
            
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
        }.animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
    }
}

struct CustomerView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerView()
    }
}
