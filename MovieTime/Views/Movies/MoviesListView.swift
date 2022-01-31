//
//  MoviesListView.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.

//

import Combine
import SwiftUI

struct MoviesListView: View {
    @ObservedObject var viewModel: MoviesListViewModel
        
    var body: some View {
        NavigationView {
            content
                .navigationBarHidden(true)
        }
        .onAppear { self.viewModel.send(event: .onAppear) }
    }
    
    private var content: some View {
        switch viewModel.state {
        case .idle:
            return Color.clear.toAnyView()
        case .loading:
            return Loader(isAnimating: true, style: .large).toAnyView()
        case .error(let error):
            return Text(error.localizedDescription).toAnyView()
        case .loaded(let movies):
            return list(of: movies).toAnyView()
        }
    }
    
    private func list(of movies: [MoviesListViewModel.MovieListItem]) -> some View {
        return List(movies) { movie in
            NavigationLink(
                destination: MovieDetailView(viewModel: MovieDetailViewModel(movieID: movie.id)),
                label: { MovieRow(movie: movie) }
            )
        }
    }
}

