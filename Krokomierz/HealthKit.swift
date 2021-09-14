//
//  CoreMotion.swift
//  Krokomierz
//
//  Created by Darek on 21/07/2021.
//

import Foundation
import HealthKit
import Combine


class HealthKitSetup{

    let healthStore = HKHealthStore()


    func enableHealthStore() -> Future<Bool,Never>{
        Future { promise in
            if HKHealthStore.isHealthDataAvailable(){
                let stepQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
                let distanceWalkingRunningQuantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
                let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
                let exerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!

                let allTypes = Set([HKObjectType.workoutType(),
                                    stepQuantityType,
                                    distanceWalkingRunningQuantityType,
                                    activeEnergyBurned,
                                    exerciseTime
                                    ])

                self.healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
                    if !success{
                        print("DEBUG: HealthStore auth failed(read)")
                        promise(.success(false))
                    } else {
                        print("DEBUG: HealthStore auth successed(read)")
                        promise(.success(true))
                    }
                }
           }
        }
    }
    
    func getSteps(selectedDay:Date, pir: DateComponents.Periods) -> Future<Double,Never>{
        Future { promise in
            let stepQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
            let components = DateComponents().forPeriod(period: pir)
            let startDate = selectedDay

            let endDate = Calendar.current.date(byAdding: components, to: startDate)!
            let predictate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: stepQuantityType,
                                          quantitySamplePredicate: predictate,
                                          options: .cumulativeSum) { _, result,_ in
                guard let result = result, let sum = result.sumQuantity() else {
                    promise(.success(0.0))
                    return
                }
                promise(.success(sum.doubleValue(for: HKUnit.count())))
            }
            self.healthStore.execute(query)
        }
    }

    func getDistance(selectedDay:Date, pir: DateComponents.Periods) -> Future<Double,Never>{
        Future { promise in
            let distanceQuantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let components = DateComponents().forPeriod(period: pir)
            let startDate = selectedDay

            let endDate = Calendar.current.date(byAdding: components, to: startDate)!
            let predictate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: distanceQuantityType,
                                          quantitySamplePredicate: predictate,
                                          options: .cumulativeSum) { _, result,_ in
                guard let result = result, let sum = result.sumQuantity() else {
                    promise(.success(0.0))
                    return
                }
                promise(.success(sum.doubleValue(for: HKUnit.meter())))
            }
            self.healthStore.execute(query)
        }
    }
    
}
