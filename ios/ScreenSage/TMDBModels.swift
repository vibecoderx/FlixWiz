//
//  TMDBModels.swift
//  ScreenSage

import Foundation

// Represents the top-level response from the TMDB trending API.
struct TMDBTrendingResponse: Codable {
    let results: [TMDBTrendingItem]
}

// Represents a single trending item, which can be a movie or a TV show.
struct TMDBTrendingItem: Codable, Identifiable {
    let id: Int
    let title: String?       // Movies have a 'title'
    let name: String?        // TV shows have a 'name'
    let poster_path: String? // The path to the poster image
    let media_type: String?  // "movie" or "tv"

    // A computed property to get the display name, whether it's a movie or TV show.
    var displayName: String {
        return title ?? name ?? "Unknown Title"
    }

    // A computed property to construct the full URL for the poster image.
    var posterURL: URL? {
        guard let path = poster_path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}

// Represents the response from the TMDB external IDs endpoint.
struct TMDBExternalIDs: Codable {
    let imdb_id: String?
}


// MARK: - TMDB Detail Models (Original, kept for reference or future use if needed)

// A universal model to hold detailed information for either a movie or a TV show.
// This simplifies the detail view by providing a consistent interface.
struct TMDBDetailModel {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    let genres: [String]

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
    }
    
    var rating: String {
        return String(format: "%.1f / 10", voteAverage)
    }
}

// Represents a genre object from the TMDB API.
struct TMDBGenre: Codable {
    let name: String
}

// Protocol to unify the structure of TMDB movie and TV show detail responses.
protocol TMDBDetailedMedia: Codable {
    var id: Int { get }
    var overview: String? { get }
    var poster_path: String? { get }
    var vote_average: Double? { get }
    var genres: [TMDBGenre]? { get }
    
    // Properties that differ between movies and TV shows
    var original_title: String? { get } // Movie
    var original_name: String? { get } // TV
    var release_date: String? { get } // Movie
    var first_air_date: String? { get } // TV
}

// Specific data model for detailed movie information from TMDB.
struct TMDBMovieDetail: TMDBDetailedMedia {
    let id: Int
    let overview: String?
    let poster_path: String?
    let vote_average: Double?
    let genres: [TMDBGenre]?
    let original_title: String?
    let release_date: String?
    
    // Conform to protocol (TV-specific properties are nil)
    var original_name: String? { nil }
    var first_air_date: String? { nil }
}

// Specific data model for detailed TV show information from TMDB.
struct TMDBTVDetail: TMDBDetailedMedia {
    let id: Int
    let overview: String?
    let poster_path: String?
    let vote_average: Double?
    let genres: [TMDBGenre]?
    let original_name: String?
    let first_air_date: String?
    
    // Conform to protocol (movie-specific properties are nil)
    var original_title: String? { nil }
    var release_date: String? { nil }
}
