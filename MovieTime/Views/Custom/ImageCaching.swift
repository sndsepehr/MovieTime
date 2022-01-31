//
//  ImageCaching.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.
//

import UIKit
import SwiftUI

protocol ImageCaching {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCaching {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCaching = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCaching {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
