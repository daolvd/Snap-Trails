//
//  CameraView.swift
//  SnapTrail
//
//  Created by Niramon Kitrattanasak on 28/4/2026.
//

import SwiftUI

struct CameraView: View {
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.snapAccent)

                Text("Capture Memory")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Camera screen coming soon.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Capture")
        }
    }
}

