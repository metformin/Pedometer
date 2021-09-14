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
    let userDef = UserDef()
    var goalSteps = CurrentValueSubject<Double,Never>(500.0)
    var healthData = CurrentValueSubject<healthActivityData,Never>(healthActivityData(distanceCounter: 0.0, energyBurnedCounter: 0.0, aciveTimeCounter: 0.0, floorsAscended: 0, floorsDescended: 0, stepsCounter: 0, tempo: 0.0))
    var subscriptions = Set<AnyCancellable>()
    let pedometer = CMPedometer()
    let calendar = Calendar.current
    
    func fetchGoalStepsAmount(){
        userDef.getGoalStepsAmountCombine()
            .sink { steps in
                self.goalSteps.send(steps)
            }.store(in: &subscriptions)
    }

    func setupStartUpdateStepsLive(){
        if CMMotionActivityManager.isActivityAvailable() {
            var fetchedData = healthActivityData(distanceCounter: 0.0, energyBurnedCounter: 0.0, aciveTimeCounter: 0.0, floorsAscended: 0, floorsDescended: 0, stepsCounter: 0, tempo: 0.0)
            print("DEBUG: START")
            pedometer.startUpdates(from: calendar.startOfDay(for: Date())) { (data, error) in
                guard let pedometerData = data else {return}
                print("CoreMotionSetup -> startUpdateStepsLive: \(pedometerData)")
                fetchedData.distanceCounter = pedometerData.distance?.doubleValue ?? 0.0
                fetchedData.stepsCounter = pedometerData.numberOfSteps.intValue
                fetchedData.energyBurnedCounter = pedometerData.numberOfSteps.doubleValue * 0.04
                fetchedData.floorsAscended = pedometerData.floorsAscended?.intValue ?? 0
                fetchedData.floorsDescended = pedometerData.floorsDescended?.intValue ?? 0
                fetchedData.tempo = pedometerData.averageActivePace?.doubleValue ?? 0.0
                
                self.healthData.send(fetchedData)
            }
        }
    }
    
    
}
