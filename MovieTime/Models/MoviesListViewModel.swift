//
//  MoviesListViewModel.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.
//

import Foundation
import Combine

final class MoviesListViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    
    private var bag = Set<AnyCancellable>()
    
    private let input = PassthroughSubject<Event, Never>()
    
    init() {
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
    
    deinit {
        bag.removeAll()
    }
    
    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner Types

extension MoviesListViewModel {
    enum State {
        case idle
        case loading
        case loaded([MovieListItem])
        case error(Error)
    }
    
    enum Event {
        case onAppear
        case onSelectMovie(Int)
        case onMoviesLoaded([MovieListItem])
        case onFaileLoadMovies(Error)
    }
    
    struct MovieListItem: Identifiable {
        let id: Int
        let title: String
        let cover: URL?
        let year: String
        
        init(movie: Movie) {
            id = movie.id
            title = movie.title
            cover = movie.cover
            year = movie.year
        }
    }
}

// MARK: - State Machine

extension MoviesListViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle:
            switch event {
            case .onAppear:
                return .loading
            default:
                return state
            }
        case .loading:
            switch event {
            case .onFaileLoadMovies(let error):
                return .error(error)
            case .onMoviesLoaded(let movies):
                return .loaded(movies)
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
            guard case .loading = state else { return Empty().eraseToAnyPublisher() }
            
            return MoviesAPI.movies()
                .map { $0.results.map(MovieListItem.init) }
                .map(Event.onMoviesLoaded)
                .catch { Just(Event.onFaileLoadMovies($0)) }
                .eraseToAnyPublisher()
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}


