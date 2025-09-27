//
//  SearchBar.swift
//  FlixWiz
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            // The main text field for user input.
            // The `onCommit` closure is called when the user presses the return key.
            TextField(placeholder, text: $text, onCommit: onSearch)
                .foregroundColor(.primary)
            
            // Magnifying glass icon on the right.
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            // A clear button (xmark.circle.fill) that appears only when
            // there is text in the search field.
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
