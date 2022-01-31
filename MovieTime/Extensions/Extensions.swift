//
//  Extensions.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.
//
import SwiftUI

extension View {
    func toAnyView() -> AnyView { AnyView(self) }
    
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
    
    
}


public var spinner: some View {
    Loader(isAnimating: true, style: .medium)
}
