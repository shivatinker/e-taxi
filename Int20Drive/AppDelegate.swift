//
//  AppDelegate.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMapsDirections
import Intents

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        INPreferences.requestSiriAuthorization { (status) in
            
        }
        
        GMSServices.provideAPIKey(DConfiguration.shared.googleApiKey)
        GMSPlacesClient.provideAPIKey(DConfiguration.shared.googleApiKey)
        GoogleMapsService.provide(apiKey: DConfiguration.shared.googleApiKey)
        
        let context = DContext()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootVC = DMainViewController(context: context)
        let rootNC = UINavigationController(rootViewController: rootVC)
        
        window?.rootViewController = rootNC
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return userActivityType == "shivatinker.Int20Drive.current_location"
    }
    
}

