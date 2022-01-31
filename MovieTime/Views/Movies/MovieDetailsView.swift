//
//  MovieDetailsView.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.
//

import SwiftUI
import Combine

struct MovieDetailView: View {
    @ObservedObject var viewModel: MovieDetailViewModel
    @Environment(\.imageCache) var cache: ImageCaching
    
    var body: some View {
        content
            .onAppear { self.viewModel.send(event: .onAppear) }
    }
    
    private var content: some View {
        switch viewModel.state {
        case .idle:
            return Color.clear.toAnyView()
        case .loading:
            return spinner.toAnyView()
        case .error(let error):
            return Text(error.localizedDescription).toAnyView()
        case .loaded(let movie):
            return self.movie(movie).toAnyView()
        }
    }
    
    private func movie(_ movie: MovieDetailViewModel.MovieDetail) -> some View {
        ScrollView (showsIndicators: false) {
            VStack(alignment: .center) {
                movie.cover.map{ url in
                    SmoothImage(url: url, cache: cache, placeholder: spinner, configuration: { $0.resizable().renderingMode(.original)}
                    )
                        .frame(width: 150, height: 180, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                }
                VStack (alignment: .leading, spacing: 8){
                    Text(movie.title)
                        .font(.title)
                        .multilineTextAlignment(.leading)
                    
                    Text(movie.year)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black.opacity(0.7))
                    
                        .font(.subheadline)
                        .padding(.bottom, 20)
                    
                    movie.overview.map {
                        Text($0)
                            .font(.body)
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                .padding()
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
    
    private var fillWidth: some View {
        HStack {
            Spacer()
        }
    }
    
    private func cover(of movie: MovieDetailViewModel.MovieDetail) -> some View {
        movie.cover.map { url in
            SmoothImage(
                url: url,
                cache: cache,
                placeholder: self.spinner,
                configuration: { $0.resizable()}
            )
                .aspectRatio(contentMode: .fit)
        }
    }
    
    private var spinner: Loader { Loader(isAnimating: true, style: .large) }
}


struct MoviewDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(viewModel: MovieDetailViewModel(movieID: 10))
    }
}

