import SwiftUI
import SwiftData

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    let categoryDataService: CategoryDataService
    @Environment(\.dismiss) private var dismiss

    @State private var showFromDatePicker = false
    @State private var showToDatePicker = false
    @State private var tempFromDate = Date()
    @State private var tempToDate = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Search field
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.snapTextSecondary)
                            TextField("Search memories...", text: $viewModel.keyword)
                                .foregroundColor(.snapTextPrimary)
                                .autocorrectionDisabled()
                                .onSubmit { viewModel.search() }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.snapCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )

                        // Category filter
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundColor(.snapTextPrimary)

                            Menu {
                                Button("All") { viewModel.selectedCategory = nil }
                                ForEach(viewModel.categories, id: \.id) { cat in
                                    Button(cat.name) { viewModel.selectedCategory = cat }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.selectedCategory?.name ?? "All")
                                        .foregroundColor(.snapTextPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.snapTextSecondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.snapCard)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                            }
                        }

                        // Date range
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date Range")
                                .font(.headline)
                                .foregroundColor(.snapTextPrimary)

                            HStack(spacing: 12) {
                                Text("From")
                                    .font(.subheadline)
                                    .foregroundColor(.snapTextSecondary)

                                Button {
                                    // CHANGED: dismiss the To picker before toggling From picker
                                    // so both pickers are never on screen at the same time
                                    showToDatePicker = false
                                    showFromDatePicker.toggle()
                                } label: {
                                    HStack {
                                        Text(viewModel.fromDate != nil
                                             ? DateFormatterHelper.displayDate(viewModel.fromDate!)
                                             : "Start")
                                            .font(.subheadline)
                                            .foregroundColor(.snapTextPrimary)
                                        Image(systemName: "calendar")
                                            .foregroundColor(.snapTextSecondary)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.snapCard)
                                    .clipShape(Capsule())
                                }

                                Text("To")
                                    .font(.subheadline)
                                    .foregroundColor(.snapTextSecondary)

                                Button {
                                    // CHANGED: dismiss the From picker before toggling To picker
                                    // so both pickers are never on screen at the same time
                                    showFromDatePicker = false
                                    showToDatePicker.toggle()
                                } label: {
                                    HStack {
                                        Text(viewModel.toDate != nil
                                             ? DateFormatterHelper.displayDate(viewModel.toDate!)
                                             : "End")
                                            .font(.subheadline)
                                            .foregroundColor(.snapTextPrimary)
                                        Image(systemName: "calendar")
                                            .foregroundColor(.snapTextSecondary)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.snapCard)
                                    .clipShape(Capsule())
                                }
                            }

                            if showFromDatePicker {
                                DatePicker("", selection: $tempFromDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .colorScheme(.dark)
                                    .tint(Color.snapAccent)
                                    .onChange(of: tempFromDate) { _, newVal in
                                        viewModel.fromDate = newVal
                                        showFromDatePicker = false
                                    }
                            }

                            if showToDatePicker {
                                DatePicker("", selection: $tempToDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .colorScheme(.dark)
                                    .tint(Color.snapAccent)
                                    .onChange(of: tempToDate) { _, newVal in
                                        viewModel.toDate = newVal
                                        showToDatePicker = false
                                    }
                            }
                        }

                        // Category chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                CategoryChipView(
                                    name: "All",
                                    isSelected: viewModel.selectedCategory == nil
                                ) {
                                    viewModel.selectedCategory = nil
                                }

                                ForEach(viewModel.categories, id: \.id) { cat in
                                    CategoryChipView(
                                        name: cat.name,
                                        isSelected: viewModel.selectedCategory?.id == cat.id
                                    ) {
                                        viewModel.selectedCategory = cat
                                    }
                                }
                            }
                        }

                        // Search button
                        Button {
                            viewModel.search()
                        } label: {
                            Text("Search")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.snapAccent)
                                .clipShape(Capsule())
                        }

                        // Results
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Results")
                                .font(.headline)
                                .foregroundColor(.snapTextPrimary)

                            if viewModel.results.isEmpty {
                                Text("No results found")
                                    .font(.subheadline)
                                    .foregroundColor(.snapTextSecondary)
                                    .padding(.top, 8)
                            } else {
                                ForEach(Array(viewModel.results.enumerated()), id: \.element.id) { index, memory in
                                    NavigationLink {
                                        MemoryDetailView(
                                            memories: viewModel.results,
                                            initialIndex: index,
                                            memoryDataService: viewModel.memoryDataService,
                                            categoryDataService: categoryDataService
                                        )
                                    } label: {
                                        searchResultRow(memory: memory)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.snapTextSecondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.resetFilters()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(Color.snapAccent)
                    }
                }
            }
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                viewModel.fetchCategories()
            }
        }
    }

    private func searchResultRow(memory: Memory) -> some View {
        HStack(spacing: 14) {
            MemoryImageView(fileName: memory.imageFileName, cornerRadius: 25)
                .frame(width: 50, height: 50)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(memory.locationName)
                    .font(.headline)
                    .foregroundColor(.snapTextPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.snapTextSecondary)
                    Text(DateFormatterHelper.displayDateTime(memory.dateTime))
                        .font(.caption)
                        .foregroundColor(.snapTextSecondary)
                }
            }

            Spacer()

            Image(systemName: memory.isFavourite ? "heart.fill" : "heart")
                .foregroundColor(memory.isFavourite ? Color.snapAccent : .snapTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.snapCard)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    SearchView(
        viewModel: SearchViewModel(
            memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
            categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
        ),
        categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
    )
    .modelContainer(PreviewContainer.shared)
}
