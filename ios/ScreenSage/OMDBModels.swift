//
//  OMDBModels.swift
//  ScreenSage
//

import Foundation

// MARK: - OMDb DATA MODELS

// Represents the response from a search query to the OMDb API.
struct SearchResponse: Codable {
    let Search: [MovieSummary]
    let totalResults: String
    let Response: String
}

// Represents a single movie summary in a search result list.
struct MovieSummary: Codable, Identifiable {
    let Title: String
    let Year: String
    let imdbID: String
    let `Type`: String
    let Poster: String
    var id: String { imdbID }
}

// Represents the detailed information for a single movie, including multiple ratings.
struct MovieDetails: Codable, Identifiable {
    let Title: String, Year: String, Rated: String, Released: String, Runtime: String, Genre: String, Director: String, Writer: String, Actors: String, Plot: String, Language: String, Country: String, Awards: String, Poster: String, Ratings: [Rating], imdbRating: String, Metascore: String
    let imdbID: String
    let `Type`: String // Added this property to enable filtering
    
    var id: String { imdbID }
    
    // Safely extracts the Rotten Tomatoes score from the ratings array.
    var rottenTomatoesScore: String {
        Ratings.first { $0.Source == "Rotten Tomatoes" }?.Value ?? "N/A"
    }
    
    // Computed property to safely access Metascore, returning "N/A" if empty or invalid.
    var metascoreValue: String {
        return Metascore == "N/A" ? "N/A" : Metascore
    }
    
    // Computed property to generate the Rotten Tomatoes search URL.
    var rottenTomatoesURL: URL? {
        guard let encodedTitle = Title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://www.rottentomatoes.com/search?search=\(encodedTitle)")
    }
}

// Represents a single rating source and its value (e.g., "Rotten Tomatoes", "90%").
struct Rating: Codable {
    let Source: String, Value: String
}
