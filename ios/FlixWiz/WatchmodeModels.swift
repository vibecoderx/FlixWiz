//
//  WatchmodeModels.swift
//  ScreenSage
//

import Foundation

// Represents the response from the Watchmode search API.
struct WatchmodeSearchResponse: Codable {
    let title_results: [WatchmodeSearchResult]
}

// Represents a single search result from Watchmode.
struct WatchmodeSearchResult: Codable {
    let id: Int
}

// Represents a single streaming source (e.g., Netflix).
struct WatchmodeSource: Codable, Identifiable {
    let source_id: Int
    let name: String
    let type: String // "sub", "rent", "buy", "free"
    let region: String // ADDED: To allow filtering by region (e.g., "US")
    
    var id: Int { source_id }
    
    // A computed property to get a user-friendly display name for the source type.
    var displayType: String {
        switch type {
        case "sub":
            return "Stream"
        case "rent":
            return "Rent"
        case "buy":
            return "Buy"
        case "free":
            return "Free"
        default:
            return type.capitalized
        }
    }
}

