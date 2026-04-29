//
//  ProfileView.swift
//  SnapTrail
//
//  Created by Niramon Kitrattanasak on 28/4/2026.
//

import SwiftUI

struct ProfileView: View {
    let viewModel: SettingsViewModel
    let memoryDataService: MemoryDataService

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.snapAccent)

                Text("Profile")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Profile screen coming soon.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Profile")
        }
    }
}
