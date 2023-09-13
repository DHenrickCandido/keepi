//
//  NewEnvelopeButtonView.swift
//  Keepi
//
//  Created by Diego Henrick on 30/08/23.
//

import SwiftUI

struct NewEnvelopeButtonView: View {
    var body: some View {
        VStack{
            Image(systemName: "plus.app.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: 48, height: 48)
                .foregroundColor(Color("darkGreenKeepi"))
                .cornerRadius(8)

            Text("Adicionar \n envelope")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color("darkGreenKeepi"))

        }
        .padding(8)
        .frame(width: 142, height: 119)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
            
        
    }
}

struct NewEnvelopeButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NewEnvelopeButtonView()
    }
}
