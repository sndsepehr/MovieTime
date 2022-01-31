//
//  MovieRow.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.
//

import SwiftUI

struct MovieRow: View {
    let movie: MoviesListViewModel.MovieListItem
    @Environment(\.imageCache) var cache: ImageCaching
    
    var body: some View {
        HStack {
            movie.cover.map { url in
                SmoothImage(
                    url: url,
                    cache: cache,
                    placeholder: spinner,
                    configuration: { $0.resizable().renderingMode(.original) }
                )
            } 
            .aspectRatio(contentMode: .fit)
            .frame(width: 90, height: 100, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                
                
                Text(movie.year)
                    .font(.subheadline)
                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
            }
            Spacer()
            
        }
    }
}
