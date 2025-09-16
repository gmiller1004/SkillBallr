//
//  SkillBallrApp.swift
//  SkillBallr
//
//  Created by Greg Miller on 9/16/25.
//

import SwiftUI

@main
struct SkillBallrApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
