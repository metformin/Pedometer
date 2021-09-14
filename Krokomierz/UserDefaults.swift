//
//  UserDefaults.swift
//  Krokomierz
//
//  Created by Darek on 12/01/2021.
//

import Foundation
import Combine

class UserDef{
    //var currentGoalStepsAmount = PassthroughSubject<Double,Never>()

    func changeGoalStepsAmount(newGoalSteps:Double){
        let userDefaults = UserDefaults.standard
        userDefaults.set(newGoalSteps, forKey: "goalSteps")
        userDefaults.synchronize()
    }
    func getGoalStepsAmount() -> Double {
        let userDefaults = UserDefaults.standard
        let newGoalStepsAmount = userDefaults.double(forKey: "goalSteps")

        if userDefaults.contains(key: "goalSteps"){
            return newGoalStepsAmount
        } else {
            return 10000.0
        }
    }
    func getGoalStepsAmountCombine() -> AnyPublisher<Double,Never>{
        Future{ promise in
            let userDefaults = UserDefaults.standard
            let newGoalStepsAmount = userDefaults.double(forKey: "goalSteps")
            if userDefaults.contains(key: "goalSteps"){
                print("DEBUG: UserDefaults 1 - getGoalStepsAmount \(newGoalStepsAmount)")
                promise(.success(newGoalStepsAmount))
            } else {
                promise(.success(500.0))
            }
        }.compactMap({$0})
        .eraseToAnyPublisher()
    }
    
    func getUserSex() -> AnyPublisher<UserDefaults.userSex,Never>{
        Future{ promise in
            let userDefaults = UserDefaults.standard
            let newSex = userDefaults.integer(forKey: "userSex")
            if userDefaults.contains(key: "userSex"){
                print("DEBUG: UserDefaults 1 - getSex \(newSex)")
                promise(.success((UserDefaults.userSex(rawValue: newSex))))
            } else {
                promise(.success(.man))
            }
        }.compactMap({$0})
        .eraseToAnyPublisher()
    }
    
    func changeUserSex(userSex: UserDefaults.userSex){
        let userDefaults = UserDefaults.standard
        userDefaults.set(userSex.rawValue, forKey: "userSex")
        userDefaults.synchronize()
    }
    
    func getUserWeight() -> AnyPublisher<Double,Never>{
        Future{ promise in
            let userDefaults = UserDefaults.standard
            let userWeight = userDefaults.double(forKey: "userWeight")
            if userDefaults.contains(key: "userWeight"){
                print("DEBUG: UserDefaults 1 - userWeight \(userWeight)")
                promise(.success((userWeight)))
            } else {
                promise(.success(30))
            }
        }.compactMap({$0})
        .eraseToAnyPublisher()
    }
    
    func changeUserWeight(userWeight: Double){
        let userDefaults = UserDefaults.standard
        userDefaults.set(userWeight, forKey: "userWeight")
        userDefaults.synchronize()
    }

}

extension UserDefaults {
    enum userSex: Int{
        case man
        case woman
    }
    func contains(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
    

