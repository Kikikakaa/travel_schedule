//
//  ContentView.swift
//  travel_schedule
//
//  Created by user on 05.09.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            runAllTests()
        }
    }
}

#Preview {
    ContentView()
}
