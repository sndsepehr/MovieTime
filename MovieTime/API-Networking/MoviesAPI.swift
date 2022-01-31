//
//  MovieAPI.swift
//  MovieTime
//
//  Created by Saifuddin Sepehr on 1/24/22.
//

import Foundation
import Combine

enum MoviesAPI {
    static let imageBase = URL(string: "https://image.tmdb.org/t/p")!
    static let imageOriginalBase = imageBase.appendingPathComponent("/original")
    static let imageW500Base = imageBase.appendingPathComponent("/w500")
    
    
    
    private static let base = URL(string: "https://api.themoviedb.org/3")!
    private static let apiKey = "c9856d0cb57c3f14bf75bdc6c063b8f3"
    private static let agent = APIAgent()
    
    static func movies() -> AnyPublisher<Page<Movie>, Error> {
        let request = URLComponents(url: base.appendingPathComponent("/discover/movie"), resolvingAgainstBaseURL: true)?
            .addingApiKey(apiKey)
            .request
        return agent.run(request!)
    }
    
    static func movieDetail(id: Int) -> AnyPublisher<MovieDetailSPR, Error> {
        print("Movie details url: ", base.appendingPathComponent("/movie/\(id)"))
        let request = URLComponents(url: base.appendingPathComponent("/movie/\(id)"), resolvingAgainstBaseURL: true)?
            .addingApiKey(apiKey)
            .request
        return agent.run(request!)
    }
}

private extension URLComponents {
    func addingApiKey(_ apiKey: String) -> URLComponents {
        var copy = self
        copy.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        return copy
    }
    
    var request: URLRequest? {
        url.map { URLRequest.init(url: $0) }
    }
}

// MARK: - Movie

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    private let poster_path: String?
    private let release_date: String?
    var year: String {
        if let release_date = release_date, let index = release_date.firstIndex(of: "-") {
            return String(release_date.prefix(upTo: index))
        }
        return "Unknown"
    }
    var cover: URL? {
        poster_path.map {MoviesAPI.imageW500Base.appendingPathComponent("\($0)")
        }
    }
}
 
