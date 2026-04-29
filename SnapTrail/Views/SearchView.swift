//
//  SearchView.swift
//  SnapTrail
//
//  Created by Niramon Kitrattanasak on 28/4/2026.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Search memories", text: $viewModel.keyword)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button("Search") {
                    viewModel.search()
                }

                List(viewModel.results, id: \.id) { memory in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(memory.locationName)
                            .font(.headline)

                        if !memory.caption.isEmpty {
                            Text(memory.caption)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.fetchCategories()
            }
        }
    }
}
