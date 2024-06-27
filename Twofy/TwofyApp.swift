//
//  TwofyApp.swift
//  Twofy
//
//  Created by Brian Michel on 6/23/24.
//

import SwiftUI

@main
struct TwofyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ViewModel())
        }
    }
}
