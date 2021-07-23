//
//  HomeViewModel.swift
//  Krokomierz
//
//  Created by Darek on 21/07/2021.
//

import Foundation
import CoreMotion
import Combine


class HomeViewModel {
    let healthKit = HealthKitSetup()
    var healthData = CurrentValueSubject<healthActivityData,Never>(healthActivityData(distanceCounter: 0.0, energyBurnedCounter: 0.0, aciveTimeCounter: 0.0, stepsCounter: 0))
    var subscriptions = Set<AnyCancellable>()
    let pedometer = CMPedometer()
    let calendar = Calendar.current
//    let coreMotionSetup = CoreMotionSetup()
    
    func setupStartUpdateStepsLive(){
        if CMMotionActivityManager.isActivityAvailable() {
            var fetchedData = healthActivityData(distanceCounter: 0.0, energyBurnedCounter: 0.0, aciveTimeCounter: 0.0, stepsCounter: 0)
            print("DEBUG: START")
            pedometer.startUpdates(from: calendar.startOfDay(for: Date())) { (data, error) in
                guard let pedometerData = data else {return}
                print("CoreMotionSetup -> startUpdateStepsLive: \(pedometerData)")
                fetchedData.distanceCounter = pedometerData.distance?.doubleValue ?? 0.0
                fetchedData.stepsCounter = pedometerData.numberOfSteps.intValue
                self.healthData.send(fetchedData)
            }
        }
    }
    
    
}
