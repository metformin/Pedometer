//
//  SettingsViewModel.swift
//  Krokomierz
//
//  Created by Darek on 01/08/2021.
//

import Foundation
import Combine


class SettingsViewModel {
    let userDef = UserDef()
    let notification = NotificationManager()
    var goalSteps =  CurrentValueSubject<Double,Never>(500.0)
    var userWeight =  CurrentValueSubject<Double,Never>(30.0)
    var userSex =  CurrentValueSubject<UserDefaults.userSex,Never>(.man)

    
    var subscriptions = Set<AnyCancellable>()

    func fetchGoalStepsAmount(){
        userDef.getGoalStepsAmountCombine()
            .sink {[weak self] steps in
                self?.goalSteps.send(steps)
            }.store(in: &subscriptions)
    }
    func fetchUserSex(){
        userDef.getUserSex()
            .sink {[weak self] sex in
                self?.userSex.send(sex)
            }.store(in: &subscriptions)
    }
    func fetchUserWeight(){
        userDef.getUserWeight()
            .sink {[weak self] weight in
                self?.userWeight.send(weight)
            }.store(in: &subscriptions)
    }
    func changeGoalSetupAmount(newGoalSteps: Double){
        userDef.changeGoalStepsAmount(newGoalSteps: newGoalSteps)
    }
    func changeUserSex(userSex: UserDefaults.userSex){
        userDef.changeUserSex(userSex: userSex)
    }
    func changeUserWeight(newUserWeight: Double){
        userDef.changeUserWeight(userWeight: newUserWeight)
    }
    func turnOnNotification(){
        notification.requestAuth().sink(receiveValue: { status in
            if status {
                self.notification.sendNotification()
            }
        }).store(in: &subscriptions)
    }
    func getPendingNotification(){
        notification.getPendingNotification()
    }

}
