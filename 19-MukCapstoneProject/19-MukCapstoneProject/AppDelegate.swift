//
//  AppDelegate.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/25/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Variables
    var mukCurrentUser: MukUser?
    var mukProfileRef: DatabaseReference?
    var mukCurrentProfile: MukProfile?
    var mukProfileHandle: DatabaseHandle?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSPlacesClient.provideAPIKey("AIzaSyBs9oj4OwaemQysFOEQvgKS_pq11uCUe6Y")
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
//        try? Auth.auth().signOut()
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let mukUser = user else { return }
            
            self?.mukCurrentUser = MukUser(mukAuthUser: mukUser)
            
            self?.mukProfileRef = Database.database().reference().child("mukProfiles").child(mukUser.uid)
            self?.mukProfileHandle = self?.mukProfileRef?.observe(.value) { snapshot in
                self?.mukCurrentProfile = MukProfile(mukSnapshot: snapshot)
                print("")
            }
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        guard let mukProfileHandle = mukProfileHandle else { return }
        
        mukProfileRef?.removeObserver(withHandle: mukProfileHandle)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

