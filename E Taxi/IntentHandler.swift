//
//  IntentHandler.swift
//  E Taxi
//
//  Created by Andrii Zinoviev on 21.02.2021.
//

import Intents

class IntentHandler: INExtension  {
    
    override func handler(for intent: INIntent) -> Any? {
        if intent is INRequestRideIntent {
            return Handler()
        }
        return .none
    }
    
    class Handler: NSObject, INRequestRideIntentHandling {
        func handle(intent: INRequestRideIntent, completion: @escaping (INRequestRideIntentResponse) -> Void) {
            let activity = NSUserActivity(activityType: "shivatinker.Int20Drive.current_location")
            let response: INRequestRideIntentResponse = INRequestRideIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
            let status = INRideStatus()
            status.userActivityForCancelingInApplication = activity
            response.rideStatus = status
            completion(response)
        }
    }
}
