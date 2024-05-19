//
//  ContentView.swift
//  ImageCrop
//
//  Created by Hidayat Abisena on 19/05/24.
//

import SwiftUI

@available(iOS 15.0, *)
struct ContentView: View {
    @State private var image: UIImage?
    @State private var showPhotoPicker = false
    
    var body: some View {
        VStack {
            if image != nil {
                CropView(image: $image)
            } else {
                Text("Select an Image")
                    .padding()
            }
            Button("Select Photo") {
                showPhotoPicker = true
            }
            .padding()
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(image: $image)
        }
    }
}

@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
