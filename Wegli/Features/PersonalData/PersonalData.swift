//
//  PersonalData.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct PersonalData: View {
    @ObservedObject var personalDataStore = PersonalDataStore()
    
    var body: some View {
        VStack {
            DataRow(title: Text("Name"), placeholder: "Max Mustermann", binding: $personalDataStore.name)
            DataRow(title: Text("Straße, Hausnr."), placeholder: "Siemensallee, 17", binding: $personalDataStore.street)
            DataRow(title: Text("PLZ Ort"), placeholder: "76341 Mannheim", binding: $personalDataStore.town)
            DataRow(title: Text("Telefon"), placeholder: "0173 2234 6642", binding: $personalDataStore.phone)
        }
    }
}

private struct DataRow: View {
    let title: Text
    let placeholder: String
    @Binding var binding: String
    let isValid: Bool = false
    
    var body: some View {
        HStack {
            if !isValid {
                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.orange)
            }
            title
            Spacer()
            TextField(placeholder, text: $binding).multilineTextAlignment(.trailing)
        }
    }
}

struct PersonalData_Previews: PreviewProvider {
    static var previews: some View {
        PersonalData()
    }
}