//
//  MainTabView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/5/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                CoreView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(1)
                
             SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color.theme.primaryBlue)
            
            ///Top Navigation Bar
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                Spacer()
                Text(tabTitle)
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                }
            }
            .padding()
            .background(
                Color.theme.background
                    .shadow(radius: 3)
            )
        }
    }
    
    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Home"
        case 1: return "Profile"
        case 2: return "Settings"
        default: return ""
        }
    }
}

#Preview {
    MainTabView()
        .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
        .previewDisplayName("iPhone 15 Pro")
}
