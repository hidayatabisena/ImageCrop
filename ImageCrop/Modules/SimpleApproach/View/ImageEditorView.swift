//
//  ImageEditorView.swift
//  ImageCrop
//
//  Created by Hidayat Abisena on 19/05/24.
//

import SwiftUI

struct ImageEditorView: View {
    @ObservedObject var vm: ImageEditorVM
    
    var body: some View {
        VStack(spacing: 24) {
            if let image = vm.rotatedImage ?? vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(Circle())
            }
            
            Button {
                vm.rotateImage()
            } label: {
                Image(systemName: "arrow.clockwise.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            
            Button {
                vm.saveImage()
            } label: {
                Text("登録する")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .navigationBarTitle("写真トリミング", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            // back button
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.black)
        })
    }
}

struct ImageEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageEditorView(vm: ImageEditorVM(image: UIImage(named: "thecat3")))
    }
}
