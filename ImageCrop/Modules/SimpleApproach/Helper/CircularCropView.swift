//
//  CircularCropView.swift
//  ImageCrop
//
//  Created by Hidayat Abisena on 20/05/24.
//

import SwiftUI
import UIKit

struct CircularCropView: UIViewRepresentable {
    @Binding var image: UIImage?
    @Binding var croppedImage: UIImage?
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: CircularCropView
        var currentScale: CGFloat = 1.0
        var currentRotation: CGFloat = 0.0
        var currentTranslation: CGPoint = .zero
        
        init(parent: CircularCropView) {
            self.parent = parent
        }
        
        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            guard let view = gesture.view else { return }
            let translation = gesture.translation(in: view.superview)
            if gesture.state == .began || gesture.state == .changed {
                view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view.superview)
            }
            if gesture.state == .ended {
                currentTranslation = CGPoint(x: currentTranslation.x + translation.x, y: currentTranslation.y + translation.y)
            }
        }

        @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
            guard let view = gesture.view else { return }
            if gesture.state == .began || gesture.state == .changed {
                view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
                gesture.scale = 1.0
            }
            if gesture.state == .ended {
                currentScale *= gesture.scale
            }
        }

        @objc func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
            guard let view = gesture.view else { return }
            if gesture.state == .began || gesture.state == .changed {
                view.transform = view.transform.rotated(by: gesture.rotation)
                gesture.rotation = 0.0
            }
            if gesture.state == .ended {
                currentRotation += gesture.rotation
            }
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        //        func cropToCircle() {
        //            guard let image = parent.image else { return }
        //
        //            let imageView = UIImageView(image: image)
        //            imageView.contentMode = .scaleAspectFit
        //            imageView.frame = CGRect(origin: .zero, size: image.size)
        //
        //            let renderer = UIGraphicsImageRenderer(size: image.size)
        //            let circularImage = renderer.image { context in
        //                let rect = CGRect(origin: .zero, size: image.size)
        //                context.cgContext.addEllipse(in: rect)
        //                context.cgContext.clip()
        //                imageView.layer.render(in: context.cgContext)
        //            }
        //
        //            parent.croppedImage = circularImage
        //        }
        
        // lagi eksperimen
        func cropToCircle() {
            guard let image = parent.image else { return }
            
            // Buat UIImageView dengan gambar asli
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(origin: .zero, size: image.size)
            
            // Terapkan transformasi yang sama ke UIImageView
            imageView.transform = CGAffineTransform(translationX: currentTranslation.x, y: currentTranslation.y)
                .scaledBy(x: currentScale, y: currentScale)
                .rotated(by: currentRotation)
            
            let renderer = UIGraphicsImageRenderer(size: image.size)
            let circularImage = renderer.image { context in
                // Terapkan transformasi ke konteks grafis
                context.cgContext.translateBy(x: image.size.width / 2, y: image.size.height / 2)
                context.cgContext.concatenate(imageView.transform)
                context.cgContext.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
                
                // Bikin jadi circle
                let rect = CGRect(origin: .zero, size: image.size)
                context.cgContext.addEllipse(in: rect)
                context.cgContext.clip()
                
                // Render gambar
                imageView.layer.render(in: context.cgContext)
            }
            
            // Crop area yang relevan dari gambar yang sudah di-transformasi
            let cropRect = CGRect(x: (image.size.width - image.size.height) / 2, y: 0, width: image.size.height, height: image.size.height)
            if let croppedCGImage = circularImage.cgImage?.cropping(to: cropRect) {
                let finalCircularImage = UIImage(cgImage: croppedCGImage)
                parent.croppedImage = finalCircularImage
            } else {
                parent.croppedImage = circularImage
            }
        }
        
        func cropAndSaveImage() {
            cropToCircle()
            if let croppedImage = parent.croppedImage {
                UIImageWriteToSavedPhotosAlbum(croppedImage, self, #selector(saveError), nil)
            }
        }
        
        @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            } else {
                print("Image saved successfully!")
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinchGesture(_:)))
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotationGesture(_:)))
        
        panGesture.delegate = context.coordinator
        pinchGesture.delegate = context.coordinator
        rotationGesture.delegate = context.coordinator
        
        imageView.addGestureRecognizer(panGesture)
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(rotationGesture)
        
        view.addSubview(imageView)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let imageView = uiView.subviews.first as? UIImageView {
            imageView.image = image
        }
    }
}
