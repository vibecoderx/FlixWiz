//
//  MovieDetailView.swift
//  FlixWiz
//

import SwiftUI

// A unified view to display detailed information about a movie or TV show.
struct MovieDetailView: View {
    // Properties to hold the initial data
    private var initialTMDBItem: TMDBTrendingItem?
    private var initialMovieDetails: MovieDetails?
    private var initialTitle: String
    
    // State for managing fetched data and loading status
    @State private var movieDetails: MovieDetails?
    @State private var streamingSources: [WatchmodeSource] = []
    @State private var isLoading = false
    @State private var isLoadingSources = false
    @State private var errorMessage: String?
    
    // Services for fetching data
    private let tmdbService = TMDBService()
    private let omdbService = OMDBService()
    private let watchmodeService = WatchmodeService()

    // Initializer for when we already have the full details (e.g., from a search).
    init(movie: MovieDetails) {
        self.initialMovieDetails = movie
        self.initialTitle = movie.Title
    }
    
    // Initializer for when we only have a trending item and need to fetch details.
    init(tmdbItem: TMDBTrendingItem) {
        self.initialTMDBItem = tmdbItem
        self.initialTitle = tmdbItem.displayName
    }

    var body: some View {
        ScrollView {
            VStack {
                if isLoading {
                    ProgressView("Loading Details...")
                        .padding(.top, 100)
                } else if let movie = movieDetails {
                    // Main content view once details are loaded
                    MovieDetailsContentView(
                        movie: movie,
                        sources: streamingSources,
                        isLoadingSources: isLoadingSources
                    )
                } else if let errorMessage = errorMessage {
                    Text("Failed to load details: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .navigationTitle(initialTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadMovieDetails)
    }

    // Main logic to load movie details when the view appears.
    private func loadMovieDetails() {
        if let movie = initialMovieDetails {
            self.movieDetails = movie
            fetchStreamingSources(for: movie.imdbID)
            return
        }
        
        guard let tmdbItem = initialTMDBItem, let mediaType = tmdbItem.media_type else {
            errorMessage = "Missing information to load details."
            return
        }
        
        isLoading = true
        
        tmdbService.fetchIMDBId(for: tmdbItem.id, mediaType: mediaType) { result in
            switch result {
            case .success(let imdbId):
                self.omdbService.fetchMovieDetails(imdbID: imdbId) { result in
                    isLoading = false
                    switch result {
                    case .success(let details):
                        self.movieDetails = details
                        // Now fetch streaming sources
                        self.fetchStreamingSources(for: imdbId)
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            case .failure(let error):
                isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // Function to fetch streaming sources from Watchmode.
    private func fetchStreamingSources(for imdbId: String) {
        isLoadingSources = true
        watchmodeService.fetchWatchmodeID(imdbID: imdbId) { result in
            switch result {
            case .success(let watchmodeId):
                self.watchmodeService.fetchStreamingSources(watchmodeID: watchmodeId) { result in
                    isLoadingSources = false
                    if case .success(let sources) = result {
                        self.streamingSources = sources
                    }
                }
            case .failure(_):
                // Silently fail if sources can't be found, as it's non-critical.
                isLoadingSources = false
            }
        }
    }
}

// The actual content of the detail view, separated for clarity.
struct MovieDetailsContentView: View {
    let movie: MovieDetails
    let sources: [WatchmodeSource]
    let isLoadingSources: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            AsyncImage(url: URL(string: movie.Poster)) { image in
                image.resizable().aspectRatio(contentMode: .fit).cornerRadius(12)
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 500).cornerRadius(12)
                    ProgressView()
                }
            }
            
            RatingsView(
                imdbRating: movie.imdbRating,
                rottenTomatoes: movie.rottenTomatoesScore,
                metacritic: movie.metascoreValue
            )
            
            Text(movie.Plot).font(.body)
            
            if let url = movie.rottenTomatoesURL {
                Link(destination: url) {
                    HStack {
                        Text("View on Rotten Tomatoes")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                DetailRow(label: "Genre", value: movie.Genre)
                DetailRow(label: "Rated", value: movie.Rated)
                DetailRow(label: "Runtime", value: movie.Runtime)
                DetailRow(label: "Actors", value: movie.Actors)
                DetailRow(label: "Director", value: movie.Director)
                DetailRow(label: "Writer", value: movie.Writer)
                DetailRow(label: "Language", value: movie.Language)
                DetailRow(label: "Country", value: movie.Country)
                DetailRow(label: "Awards", value: movie.Awards)
            }.padding().background(Color.gray.opacity(0.1)).cornerRadius(10)
            
            // New Streaming Sources View
            StreamingSourcesView(sources: sources, isLoading: isLoadingSources)

        }.padding()
    }
}

// A new view to display the streaming availability sources.
struct StreamingSourcesView: View {
    let sources: [WatchmodeSource]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Where to Watch")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
            if isLoading {
                ProgressView()
            } else if sources.isEmpty {
                Text("Not available for streaming, renting, or purchase in the US at this time.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(sources) { source in
                        HStack {
                            Text(source.name)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(source.displayType)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(source.type == "sub" ? Color.green : Color.clear)
                                .foregroundColor(source.type == "sub" ? .white : .secondary)
                                .cornerRadius(6)
                        }
                        .padding(.vertical, 10)
                        
                        // Add a divider for all but the last item
                        if source.id != sources.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}


// A view to display IMDb, Rotten Tomatoes, and Metacritic ratings in a row.
struct RatingsView: View {
    let imdbRating: String
    let rottenTomatoes: String
    let metacritic: String
    
    var body: some View {
        HStack {
            RatingPill(name: "IMDb", score: imdbRating, color: .yellow)
            Spacer()
            RatingPill(name: "Rotten Tomatoes", score: rottenTomatoes, color: .red)
            Spacer()
            RatingPill(name: "Metacritic", score: metacritic, color: .green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// A view for a single rating pill (e.g., IMDb).
struct RatingPill: View {
    let name: String
    let score: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(color)
                Text(score)
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
    }
}

// A helper view to display a labeled piece of information (e.g., "Genre: Action").
struct DetailRow: View {
    let label: String, value: String
    var body: some View {
        HStack(alignment: .top) {
            Text("\(label):").font(.headline).frame(width: 80, alignment: .leading)
            Text(value).font(.body)
        }
    }
}

