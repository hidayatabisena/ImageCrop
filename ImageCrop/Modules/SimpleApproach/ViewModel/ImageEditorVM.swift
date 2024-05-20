//
//  ImageEditorVM.swift
//  ImageCrop
//
//  Created by Hidayat Abisena on 19/05/24.
//

import Foundation
import SwiftUI

class ImageEditorVM: ObservableObject {
    @Published var image: UIImage? {
        didSet {
            croppedImage = image
        }
    }
    // @Published var rotatedImage: UIImage?
    @Published var croppedImage: UIImage?
    @Published var isImagePickerPresented = false
    private var rotationAngle: CGFloat = 0
    
    init(image: UIImage?) {
        self.image = image
        self.croppedImage = image
    }
    
    func rotateImage() {
        guard let image = image else { return }
        rotationAngle += 90
        if rotationAngle == 360 { rotationAngle = 0 }
        
        let radians = rotationAngle * CGFloat.pi / 180
        var newImage: UIImage?
        
        if let cgImage = image.cgImage {
            let rotatedSize = CGSize(width: image.size.height, height: image.size.width)
            UIGraphicsBeginImageContext(rotatedSize)
            if let context = UIGraphicsGetCurrentContext() {
                context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
                context.rotate(by: radians)
                context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
                context.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
                newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
        
        self.croppedImage = newImage
    }
    
    //    func saveImage() {
    //        guard let rotatedImage = rotatedImage else { return }
    //        let circularImage = cropToCircle(image: rotatedImage)
    //        UIImageWriteToSavedPhotosAlbum(circularImage, nil, nil, nil)
    //    }
    
    //    func saveImage() {
    //        guard let croppedImage = croppedImage else { return }
    //        let circularImage = cropToCircle(image: croppedImage)
    //        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
    //    }
    
    var coordinator: CircularCropView.Coordinator?
    
    func saveImage() {
        coordinator?.cropAndSaveImage()
    }
    
    private func cropToCircle(image: UIImage) -> UIImage {
        let minDimension = min(image.size.width, image.size.height)
        let size = CGSize(width: minDimension, height: minDimension)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: .zero, size: size)
        context.addEllipse(in: rect)
        context.clip()
        
        image.draw(in: CGRect(
            x: (size.width - image.size.width) / 2,
            y: (size.height - image.size.height) / 2,
            width: image.size.width,
            height: image.size.height
        ))
        
        let circularImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return circularImage
    }
}
