//
//  ContentView.swift
//  AfekaFinal
//
//  Created by flash on 18/07/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "receipt.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("מחשבון חלוקת חשבונות")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
