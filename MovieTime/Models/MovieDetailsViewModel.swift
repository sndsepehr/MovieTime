//
//  MovieDetailsViewModel.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.
//

import Foundation
import Combine

final class MovieDetailViewModel: ObservableObject {
    @Published private(set) var state: State
    
    private var bag = Set<AnyCancellable>()
    
    private let input = PassthroughSubject<Event, Never>()
    
    init(movieID: Int) {
        state = .idle(movieID)
        Publishers.system(
            initial: state,
            reduce: Self.reduce, 
            scheduler: RunLoop.main,
            feedbacks: [
                Self.whenLoading(),
                Self.userInput(input: input.eraseToAnyPublisher())
            ]
        )
        .assign(to: \.state, on: self)
        .store(in: &bag)
    }
    
    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Extension MoviewDetailsViewModel

extension MovieDetailViewModel {
    enum State {
        case idle(Int)
        case loading(Int)
        case loaded(MovieDetail)
        case error(Error)
    }
    
    enum Event {
        case onAppear
        case onLoaded(MovieDetail)
        case onFaileLoad(Error)
    }
    
    struct MovieDetail {
        let id: Int
        let title: String
        let overview: String?
        private let cover_: String?
        private let relasedYear: String?
        let rating: Float?
        let genres: [String]
        let language: String
        
        
        init(movie: MovieDetailSPR) {
            id = movie.id
            title = movie.title
            overview = movie.overview
            cover_ = movie.poster_path
            rating = movie.vote_average
            genres = movie.genres.map(\.name)
            relasedYear = movie.release_date
            language = movie.original_language
        }
        
        var cover: URL? {
            cover_.map { MoviesAPI.imageW500Base.appendingPathComponent($0) }
        }
        var year: String {
            if let relasedYear = relasedYear, let index = relasedYear.firstIndex(of: "-") {
                return String(relasedYear.prefix(upTo: index))
            }
            return "Unknown"
        }
    }
}

// MARK: - The State

extension MovieDetailViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle(let id):
            switch event {
            case .onAppear:
                return .loading(id)
            default:
                return state
            }
        case .loading:
            switch event {
            case .onFaileLoad(let error):
                return .error(error)
            case .onLoaded(let movie):
                return .loaded(movie)
            default:
                return state
            }
        case .loaded:
            return state
        case .error:
            return state
        }
    }
    
    static func whenLoading() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading(let id) = state else { return Empty().eraseToAnyPublisher() }
            return MoviesAPI.movieDetail(id: id)
                .map(MovieDetail.init)
                .map(Event.onLoaded)
                .catch { Just(Event.onFaileLoad($0)) }
                .eraseToAnyPublisher()
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback(run: { _ in
            return input
        })
    }
}

struct MovieDetailSPR: Codable {
    let adult: Bool
    let backdrop_path: String?
    let belongs_to_collection: BelongsToCollection?
    let budget: Double?
    let genres: [GenreDetails]
    let homepage: String?
    let id: Int
    let imdb_id: String?
    let original_language: String
    let original_title: String?
    let overview: String?
    let popularity: Double?
    let poster_path: String?
    let production_companies: [ProductionCompanies]
    let production_countries: [ProductionContries]
    let release_date: String?
    let revenue: Double?
    let runtime: Int
    let spoken_languages: [Language]
    let status: String
    let tagline: String?
    let title: String
    let video: Bool?
    let vote_average: Float?
    let vote_count: Int?
    
    struct Genre: Codable {
        let id: Int
        let name: Int
    }
    
    struct GenreDetails: Codable {
        let id: Int
        let name: String
    }
    
    struct ProductionCompanies: Codable {
        let id: Int
        let logo_path: String?
        let name: String
        let origin_country: String
    }
    
    struct BelongsToCollection: Codable {
        let id: Int
        let name: String
        let poster_path: String?
        let backdrop_path: String?
    }
    
    struct ProductionContries: Codable {
        let iso_3166_1: String
        let name: String
    }

    struct Language: Codable {
        let english_name: String
        let iso_639_1: String
        let name: String
    }
}

struct Page<T: Codable>: Codable {
    let page: Int?
    let total_results: Int?
    let total_pages: Int?
    let results: [T]
}

