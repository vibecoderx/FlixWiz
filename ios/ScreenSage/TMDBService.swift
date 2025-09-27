import Foundation

// A service class dedicated to handling API requests to The Movie Database (TMDB).
class TMDBService {
    
    // Fetches the weekly trending movies and TV shows.
    func fetchTrending(completion: @escaping (Result<[TMDBTrendingItem], Error>) -> Void) {
        let apiKey = ApiKeys.tmdb
        guard !apiKey.isEmpty else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "TMDB API Key is missing or invalid. Please add it to Secrets.xcconfig."])
            completion(.failure(error))
            return
        }

        let urlString = "https://api.themoviedb.org/3/trending/all/week?api_key=\(apiKey)"
        fetchData(urlString: urlString, modelType: TMDBTrendingResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Fetches the IMDb ID for a given TMDB item.
    func fetchIMDBId(for id: Int, mediaType: String, completion: @escaping (Result<String, Error>) -> Void) {
        let apiKey = ApiKeys.tmdb
        guard !apiKey.isEmpty else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "TMDB API Key is missing."])
            completion(.failure(error))
            return
        }
        
        let urlString = "https://api.themoviedb.org/3/\(mediaType)/\(id)/external_ids?api_key=\(apiKey)"
        fetchData(urlString: urlString, modelType: TMDBExternalIDs.self) { result in
            switch result {
            case .success(let externalIDs):
                if let imdbId = externalIDs.imdb_id, !imdbId.isEmpty {
                    completion(.success(imdbId))
                } else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "IMDb ID not found for this item."])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Generic helper function to fetch and decode data from a URL.
    private func fetchData<T: Codable>(urlString: String, modelType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            completion(.failure(error))
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
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
