//
//  SimpleApproachView.swift
//  ImageCrop
//
//  Created by Hidayat Abisena on 19/05/24.
//

import SwiftUI

struct SimpleApproachView: View {
    var body: some View {
        NavigationView {
            ImageEditorView(vm: ImageEditorVM(image: UIImage(named: "thecat3")))
        }
    }
}

#Preview {
    SimpleApproachView()
}
