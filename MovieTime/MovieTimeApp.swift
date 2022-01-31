//
//  MovieTimeApp.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.
//

import SwiftUI

@main
struct MovieTimeApp: App {
    var body: some Scene {
        WindowGroup {
            MoviesListView(viewModel: MoviesListViewModel())
        } 
    }
}
