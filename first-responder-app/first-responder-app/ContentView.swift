//
//  ContentView.swift
//  first-responder-app
//
//  Created by Arpan Dhatt on 4/24/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        if viewModel.page == "intro"{
            introView()
        }
        else if viewModel.page == "responder"{
            ResponderView()
        }
        else if viewModel.page == "customer"{
            CustomerView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewModel())
    }
}
