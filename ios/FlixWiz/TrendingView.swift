//
//  TrendingView.swift
//  ScreenSage
//

import SwiftUI

// A view that displays a horizontally scrolling list of trending items.
struct TrendingView: View {
    let items: [TMDBTrendingItem]
    let title: String // The title for the section (e.g., "Trending This Week")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header now uses the title property
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            // The horizontal scroll view for the posters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { item in
                        // Each item now navigates to the unified MovieDetailView.
                        NavigationLink(destination: MovieDetailView(tmdbItem: item)) {
                            VStack(alignment: .leading, spacing: 8) {
                                // Asynchronously load and display the poster image
                                AsyncImage(url: item.posterURL) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    // A placeholder view while the image is loading
                                    ZStack {
                                        Color.gray.opacity(0.3)
                                        ProgressView()
                                    }
                                }
                                .frame(width: 140, height: 210)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                                
                                // Display the title of the movie or TV show
                                Text(item.displayName)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .frame(width: 140, alignment: .leading)
                                    .foregroundColor(.primary) // Ensure text is visible in dark/light mode
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // Ensures the link works correctly inside a ScrollView
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .padding(.top)
    }
}
