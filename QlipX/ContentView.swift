//
//  ContentView.swift
//  QlipX
//
//  Created by Seyed Emad Armoun on 15/05/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: QlipXStore

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Categories: \(store.categories.count)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(QlipXStore())
}
