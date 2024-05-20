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
            //            if let image = vm.rotatedImage ?? vm.image {
            //                Image(uiImage: image)
            //                    .resizable()
            //                    .scaledToFit()
            //                    .frame(height: 300)
            //                    .clipShape(Circle())
            //            }
            if vm.image != nil {
                CircularCropView(image: $vm.image, croppedImage: $vm.croppedImage)
                    .frame(height: 300)
                    .clipShape(Circle())
                    .padding()
                    .onAppear {
                        if vm.coordinator == nil {
                            vm.coordinator = CircularCropView(image: $vm.image, croppedImage: $vm.croppedImage).makeCoordinator()
                        }
                    }
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
            
            Button(action: {
                vm.isImagePickerPresented = true
            }) {
                Text("Open Gallery")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarTitle("写真トリミング", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            // back button
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.black)
        })
        .sheet(isPresented: $vm.isImagePickerPresented) {
            ImagePicker(selectedImage: $vm.image)
        }
    }
}

struct ImageEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageEditorView(vm: ImageEditorVM(image: UIImage(named: "thecat3")))
    }
}
