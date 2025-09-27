import Foundation

class WatchmodeService {
    
    // Fetches the Watchmode ID for a given IMDb ID.
    func fetchWatchmodeID(imdbID: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let apiKey = ApiKeys.watchmode
        guard !apiKey.isEmpty else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Watchmode API Key is missing."])
            completion(.failure(error))
            return
        }
        
        let urlString = "https://api.watchmode.com/v1/search/?apiKey=\(apiKey)&search_field=imdb_id&search_value=\(imdbID)"
        
        fetchData(urlString: urlString, modelType: WatchmodeSearchResponse.self) { result in
            switch result {
            case .success(let searchResponse):
                if let firstResult = searchResponse.title_results.first {
                    completion(.success(firstResult.id))
                } else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No Watchmode title found for IMDb ID."])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Fetches and processes the streaming sources for a given Watchmode title ID.
    func fetchStreamingSources(watchmodeID: Int, completion: @escaping (Result<[WatchmodeSource], Error>) -> Void) {
        let apiKey = ApiKeys.watchmode
        guard !apiKey.isEmpty else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Watchmode API Key is missing."])
            completion(.failure(error))
            return
        }
        
        let urlString = "https://api.watchmode.com/v1/title/\(watchmodeID)/sources/?apiKey=\(apiKey)"
        
        fetchData(urlString: urlString, modelType: [WatchmodeSource].self) { result in
            switch result {
            case .success(let sources):
                // 1. Filter sources to only include those from the "US" region.
                let usSources = sources.filter { $0.region == "US" }
                
                // 2. De-duplicate the sources by their name.
                var uniqueSources: [WatchmodeSource] = []
                var seenNames = Set<String>()
                
                for source in usSources {
                    if !seenNames.contains(source.name) {
                        uniqueSources.append(source)
                        seenNames.insert(source.name)
                    }
                }
                
                // 3. Sort the unique sources alphabetically by name.
                let sortedSources = uniqueSources.sorted { $0.name < $1.name }
                
                completion(.success(sortedSources))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Generic helper function to fetch and decode data.
    private func fetchData<T: Codable>(urlString: String, modelType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
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
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

