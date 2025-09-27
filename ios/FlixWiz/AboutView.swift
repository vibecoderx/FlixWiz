//
//  AboutView.swift
//  FlixWiz
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 20) {
                        Image("FlixWiz_img")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 5)
                        
                        Text("FlixWiz")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(AppInfoHelper.versionInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Commit: \(AppInfoHelper.gitCommitSHA)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section(header: Text("Data Source")) {
                    Text("This app uses data provided by TMDB, OMDb and Watchmode APIs.")
                    if let url = URL(string: "https://github.com/vibecoderx/ScreenSage?tab=readme-ov-file#-acknowledgments") {
                        Link("See links to data sources here.", destination: url)
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

