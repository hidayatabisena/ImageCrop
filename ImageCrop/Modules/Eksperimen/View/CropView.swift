//
//  CropView.swift
//  ImageCrop
//
//  Created by Hidayat Abisena on 19/05/24.
//

import SwiftUI

struct CropView: View {
    @Binding var image: UIImage?
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack {
            if let image = image {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(rotation))
                        .gesture(RotationGesture().onChanged { angle in
                            self.rotation = angle.degrees
                        })
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                HStack {
                    Button("Rotate") {
                        rotation += 90
                    }
                    .padding()
                    Button("Save") {
                        saveCroppedImage()
                    }
                    .padding()
                }
            } else {
                Text("No Image Selected")
            }
        }
    }
    
    func saveCroppedImage() {
        guard let image = image else { return }
        
        let renderer = UIGraphicsImageRenderer(size: image.size, format: UIGraphicsImageRendererFormat.default())
        let rotatedImage = renderer.image { context in
            context.cgContext.translateBy(x: image.size.width / 2, y: image.size.height / 2)
            context.cgContext.rotate(by: CGFloat(rotation * .pi / 180))
            context.cgContext.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
            image.draw(at: .zero)
        }
        
        let cropSize = min(rotatedImage.size.width, rotatedImage.size.height)
        let cropRect = CGRect(x: (rotatedImage.size.width - cropSize) / 2, y: (rotatedImage.size.height - cropSize) / 2, width: cropSize, height: cropSize)
        let croppedCGImage = rotatedImage.cgImage!.cropping(to: cropRect)!
        let croppedImage = UIImage(cgImage: croppedCGImage)
        
        let circleRenderer = UIGraphicsImageRenderer(size: CGSize(width: cropSize, height: cropSize), format: UIGraphicsImageRendererFormat.default())
        let circleImage = circleRenderer.image { context in
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: cropSize, height: cropSize)))
            context.cgContext.addPath(circlePath.cgPath)
            context.cgContext.clip()
            croppedImage.draw(in: CGRect(origin: .zero, size: CGSize(width: cropSize, height: cropSize)))
        }
        
        UIImageWriteToSavedPhotosAlbum(circleImage, nil, nil, nil)
    }
}

struct CropView_Previews: PreviewProvider {
    @State static var image: UIImage? = UIImage(systemName: "photo")
    
    static var previews: some View {
        CropView(image: $image)
    }
}
