//
//  SmoothImage.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.
//

import SwiftUI

struct SmoothImage<Placeholder: View>: View {
    @ObservedObject private var loader: ImageLoadeing
    private let placeholder: Placeholder?
    private let configuration: (Image) -> Image
    
    init(url: URL, cache: ImageCaching? = nil, placeholder: Placeholder? = nil, configuration: @escaping (Image) -> Image = { $0 }) {
        loader = ImageLoadeing(url: url, cache: cache)
        self.placeholder = placeholder
        self.configuration = configuration
    }
    
    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: some View {
        Group {
            if loader.image != nil {
                configuration(Image(uiImage: loader.image!))
            } else {
                placeholder
            }
        }
    }
}

