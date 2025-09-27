import Foundation
import SwiftUI

// A service class for handling API requests to the OMDb API.
class OMDBService {
    
    // Fetches detailed information for a movie using its IMDb ID.
    func fetchMovieDetails(imdbID: String, completion: @escaping (Result<MovieDetails, Error>) -> Void) {
        let apiKey = ApiKeys.omdb
        
        let urlString = "https://www.omdbapi.com/?i=\(imdbID)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received."])
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            do {
                let movieDetail = try JSONDecoder().decode(MovieDetails.self, from: data)
                DispatchQueue.main.async { completion(.success(movieDetail)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    // Searches for movies and fetches detailed information for each result.
    func searchMovies(query: String, completion: @escaping (Result<[MovieDetails], Error>) -> Void) {
        let apiKey = ApiKeys.omdb
        let searchFormatted = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let searchURLString = "https://www.omdbapi.com/?s=\(searchFormatted)&apikey=\(apiKey)"
        
        guard let searchURL = URL(string: searchURLString) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid search URL."])
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: searchURL) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data from search."])
                DispatchQueue.main.async { completion(.failure(noDataError)) }
                return
            }
            
            guard let searchResponse = try? JSONDecoder().decode(SearchResponse.self, from: data), searchResponse.Response == "True" else {
                let noResultsError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No movies found for '\(query)'."])
                DispatchQueue.main.async { completion(.failure(noResultsError)) }
                return
            }
            
            self.fetchDetailsForAll(summaries: searchResponse.Search, completion: completion)
        }.resume()
    }
    
    // Helper function to fetch details for an array of movie summaries.
    private func fetchDetailsForAll(summaries: [MovieSummary], completion: @escaping (Result<[MovieDetails], Error>) -> Void) {
        let group = DispatchGroup()
        var detailedMovies: [MovieDetails] = []
        
        for summary in summaries {
            group.enter()
            fetchMovieDetails(imdbID: summary.imdbID) { result in
                if case .success(let movieDetail) = result {
                    detailedMovies.append(movieDetail)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            detailedMovies.sort {
                let year1 = $0.Year.prefix(4)
                let year2 = $1.Year.prefix(4)
                return year1 > year2
            }
            completion(.success(detailedMovies))
        }
    }
}
