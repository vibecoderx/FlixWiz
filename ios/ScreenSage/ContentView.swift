import SwiftUI

// MARK: - FILTER TYPE ENUM
// Defines the possible filter states for the search results.
enum FilterType: String, CaseIterable, Identifiable {
    case all = "All"
    case movie = "Movies"
    case series = "TV Shows"
    
    var id: String { self.rawValue }
    
    var omdbType: String {
        switch self {
        case .all: return ""
        case .movie: return "movie"
        case .series: return "series"
        }
    }
}

// MARK: - MAIN CONTENT VIEW
struct ContentView: View {
    
    @State private var searchText: String = ""
    @State private var movies: [MovieDetails] = [] // This holds all search results
    @State private var trendingItems: [TMDBTrendingItem] = []
    @State private var isLoading: Bool = false
    @State private var searchMessage: String = "Discover movies and TV shows."
    @State private var selectedFilter: FilterType = .all // State for the filter
    
    private let tmdbService = TMDBService()
    private let omdbService = OMDBService()
    
    // Computed properties to split trending items into two rows.
    var trendingRowOne: [TMDBTrendingItem] { Array(trendingItems.prefix(10)) }
    var trendingRowTwo: [TMDBTrendingItem] { Array(trendingItems.suffix(from: 10)) }
    
    // Computed property to filter the movies based on the selected filter.
    var filteredMovies: [MovieDetails] {
        guard selectedFilter != .all else {
            return movies
        }
        return movies.filter { $0.Type == selectedFilter.omdbType }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText, placeholder: "Search movies & TV shows...", onSearch: searchMovies)
                    .padding(.vertical, 10)
                ScrollView {
                    VStack {
                        // Show trending views if there are no search results.
                        if !trendingItems.isEmpty && movies.isEmpty {
                            TrendingView(items: trendingRowOne, title: "Trending This Week")
                            TrendingView(items: trendingRowTwo, title: "More to Discover")
                        }
                        
                        if isLoading {
                            ProgressView("Searching...").padding(.top, 50)
                        } else if !movies.isEmpty {
                            // Display search results using the filtered list.
                            LazyVStack(spacing: 15) {
                                ForEach(filteredMovies) { movie in
                                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                                        MovieTile(movie: movie)
                                    }.buttonStyle(PlainButtonStyle())
                                }
                            }.padding()
                        } else if !searchMessage.isEmpty {
                            Text(searchMessage)
                                .foregroundColor(.secondary)
                                .padding(.top, 50)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                Text(getAppVersionInfo())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Screen Sage")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Add the filter menu only when there are search results.
                if !movies.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Picker("Filter", selection: $selectedFilter) {
                                ForEach(FilterType.allCases) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                        }
                    }
                }
            }
            .onAppear(perform: loadTrending)
        }
    }
    
    // Function to get the app's version and build number
    private func getAppVersionInfo() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as? String ?? "N/A"
        let build = dictionary["CFBundleVersion"] as? String ?? "N/A"
        
        return "Version: \(version) (Build: \(build))"
    }
    
    // MARK: - NETWORKING
    
    // Fetches trending items from TMDB when the view first appears.
    func loadTrending() {
        guard trendingItems.isEmpty else { return }
        
        tmdbService.fetchTrending { result in
            // Use a slight delay to ensure the UI remains responsive.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                switch result {
                case .success(let items):
                    // Animate the appearance of the trending rows.
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.trendingItems = items
                    }
                    self.searchMessage = ""
                case .failure(let error):
                    self.searchMessage = error.localizedDescription
                    print("Error fetching trending items: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Initiates a search for movies using the OMDb service.
    func searchMovies() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.movies = []
            self.searchMessage = ""
            return
        }
        
        // Dismiss the keyboard.
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        isLoading = true
        movies = []
        searchMessage = ""
        selectedFilter = .all // Reset filter on new search
        
        omdbService.searchMovies(query: searchText) { result in
            isLoading = false
            switch result {
            case .success(let detailedMovies):
                self.movies = detailedMovies
            case .failure(let error):
                self.searchMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - MOVIE TILE VIEW
// A view for displaying a single search result item.
struct MovieTile: View {
    let movie: MovieDetails
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            AsyncImage(url: URL(string: movie.Poster)) { image in image.resizable() }
            placeholder: { ZStack { Color.gray.opacity(0.3); ProgressView() } }
            .frame(width: 100, height: 150).cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(movie.Title).font(.headline)
                Text("Type: \(movie.Type.capitalized)").font(.subheadline) // Show the type
                Text("Year: \(movie.Year)").font(.subheadline)
                Text("IMDb: \(movie.imdbRating)").font(.subheadline)
                Text("RT: \(movie.rottenTomatoesScore)").font(.subheadline)
                Text("Director: \(movie.Director)").font(.caption).foregroundColor(.secondary).padding(.top, 5)
            }
            Spacer()
        }.padding(.vertical, 5).contentShape(Rectangle())
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

