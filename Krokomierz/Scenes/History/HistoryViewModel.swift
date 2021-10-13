//
//  HistoryViewModel.swift
//  Krokomierz
//
//  Created by Darek on 22/07/2021.
//

import Foundation
import Combine

class HistoryViewModel {
    enum activityType {
        case steps, distance, calories
    }
    struct DateRange {
        var startDate: Date
        var endDate: Date?
        init(){
            startDate = Date()
        }
    }
    lazy var healthKit = HealthKitSetup()
    var subscriptions = Set<AnyCancellable>()
    var selectedAcvitityType: activityType = .steps
    var components = DateComponents()

    var dataForOneDay = PassthroughSubject<[Date:Double],Never>()
    var dataForOneWeek = PassthroughSubject<[Date:Double],Never>()
    var dataForOneYear = PassthroughSubject<[Date:Double],Never>()
    
    init(){
        healthKit.enableHealthStore()
    }
    
    var day = DateRange() {
        didSet{
            getDataForSpecificPeriodTime(selectedDate: day.startDate, activity: selectedAcvitityType, period: .oneHour)
                .sink { [weak self] steps in
                    self?.dataForOneDay.send(steps)
                }.store(in: &subscriptions)
        }
    }
    var week = DateRange() {
        didSet{
            getDataForSpecificPeriodTime(selectedDate: week.startDate, activity: selectedAcvitityType, period: .oneDay)
                .sink { [weak self] steps in
                    self?.dataForOneWeek.send(steps)
                }.store(in: &subscriptions)
        }
    }
    var year = DateRange() {
        didSet{
            getDataForSpecificPeriodTime(selectedDate: year.startDate, activity: selectedAcvitityType, period: .oneMonth)
                .sink { [weak self] steps in
                    self?.dataForOneYear.send(steps)
                }.store(in: &subscriptions)
        }
    }
    
    //MARK: - Button Actions
    func dayButtonBackDidTapped(){
        components.day = -1
        let backDay = Calendar.current.date(byAdding: components, to: day.startDate)!
        getDayRange(forSelectedDate: backDay)
    }
    func dayButtonNextDidTapped(){
        components.day = 1
        let nextDay = Calendar.current.date(byAdding: components, to: day.startDate)!
        getDayRange(forSelectedDate: nextDay)
    }
    func weekButtonBackDidTapped(){
        components.day = -1
        let backWeek = Calendar.current.date(byAdding: components, to: week.startDate)!
        getWeekRange(forSelectedDate: backWeek)
    }
    func weekButtonNextDidTapped(){
        components.day = 7
        let nextWeek = Calendar.current.date(byAdding: components, to: week.startDate)!
        getWeekRange(forSelectedDate: nextWeek)
    }
    func yearButtonBackDidTapped(){
        components.year = -1
        print("Back year button tapped")
        let backYear = Calendar.current.date(byAdding: components, to: year.startDate)!
        getYearRange(forSelectedDate: backYear)
    }
    func yearButtonNextDidTapped(){
        print("Next year button tapped")

        components.year = 1
        let nextYear = Calendar.current.date(byAdding: components, to: year.startDate)!
        getYearRange(forSelectedDate: nextYear)
    }
    

    
    //MARK: - Get Date Range
    func getDayRange(forSelectedDate: Date) {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: forSelectedDate)
        day.startDate = startDay
    }
    func getWeekRange(forSelectedDate: Date) {
        let startWeek = forSelectedDate.startOfWeek()
        let endWeek = Calendar.current.date(byAdding: components, to: startWeek)!
        week.startDate = startWeek
    }
    func getYearRange(forSelectedDate: Date) {
        let startMonth = forSelectedDate.startOfYear
        year.startDate = startMonth
    }
    
    func fetchData(){
        getDayRange(forSelectedDate: Date())
        getWeekRange(forSelectedDate: Date())
        getYearRange(forSelectedDate: Date())
    }


    //MARK: - Get Data For Specific Period Time
    func getDataForSpecificPeriodTime(selectedDate: Date, activity: activityType, period: DateComponents.Periods) -> Future<[Date:Double],Never>{
        Future { promise in
            var components = DateComponents()
            var data = [Date:Double]()
            var max: Int

            switch period {
            case .oneHour:
                max = 23
            case .oneDay:
                max = 6
            case .oneMonth:
                max = 11
            }
      
            let myGroup = DispatchGroup()

                for i in 0...max{
                    myGroup.enter()
                    switch period {
                    case .oneHour:
                        components.hour = i
                    case .oneDay:
                        components.day = i
                    case .oneMonth:
                        components.month = i
                    }
                    
                    let checkDay = Calendar.current.date(byAdding: components, to: selectedDate)!
                    
                    switch activity {
                    case .steps:
                        self.healthKit.getSteps(selectedDay: checkDay, pir: period)
                            .sink { steps in
                                data[checkDay] = steps
                                myGroup.leave()
                            }.store(in: &self.subscriptions)
                        break
                    case .distance:
                        self.healthKit.getDistance(selectedDay: checkDay, pir: period)
                            .sink { distance in
                                data[checkDay] = distance
                                myGroup.leave()
                            }.store(in: &self.subscriptions)
                        break
                    case .calories:
                        self.healthKit.getSteps(selectedDay: checkDay, pir: period)
                            .sink { steps in
                                data[checkDay] = (steps*0.04)
                                myGroup.leave()
                            }.store(in: &self.subscriptions)
                    }
                }
            myGroup.notify(queue:.main){
                promise(.success(data))
            }
            
        }
    }
    
}
