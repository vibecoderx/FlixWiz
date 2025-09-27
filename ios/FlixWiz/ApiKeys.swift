//
//  ApiKeys.swift
//  FlixWiz
//


import Foundation

// A centralized structure for accessing API keys from the main app bundle.
// This approach reads keys from the Info.plist, which are populated by the
// Secrets.xcconfig file at build time.
struct ApiKeys {
    
    // Helper function to retrieve a key from the bundle's Info.plist.
    private static func getKey(named keyName: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: keyName) as? String else {
            fatalError("API Key '\(keyName)' not found in Info.plist. Make sure it is set in your Secrets.xcconfig file and linked in the Info tab of your target.")
        }
        return value
    }
    
    // Public accessors for each API key.
    static var tmdb: String {
        getKey(named: "TMDB_API_KEY")
    }
    
    static var omdb: String {
        getKey(named: "OMDB_API_KEY")
    }
    
    static var watchmode: String {
        getKey(named: "WATCHMODE_API_KEY")
    }
}
