//
//  UserDefaults.swift
//  Krokomierz
//
//  Created by Darek on 12/01/2021.
//

import Foundation





public func changeGoalStepsAmount(newGoalSteps:Double){
    let userDefaults = UserDefaults.standard
    userDefaults.set(newGoalSteps, forKey: "goalSteps")
    userDefaults.synchronize()
}
public func getGoalStepsAmount() -> Double {
    let userDefaults = UserDefaults.standard
    let newGoalStepsAmount = userDefaults.double(forKey: "goalSteps")

    if userDefaults.contains(key: "goalSteps"){
        return newGoalStepsAmount
    } else {
        return 10000.0
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
    

