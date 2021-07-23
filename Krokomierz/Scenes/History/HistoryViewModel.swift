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
    let healthKit = HealthKitSetup()
    var subscriptions = Set<AnyCancellable>()
    var selectedAcvitityType: activityType = .steps

    var dataForOneDay = PassthroughSubject<[Date:Double],Never>()
    var dataForOneWeek = PassthroughSubject<[Date:Double],Never>()
    var dataForOneYear = PassthroughSubject<[Date:Double],Never>()

    var day = DateRange() {
        didSet{
            getDataForSpecificPeriodTime(selectedDate: day.startDate, activity: selectedAcvitityType, period: .oneHour)
                .sink { [weak self] steps in
                    print("Downlaoded steps: \(steps)")
                    self?.dataForOneDay.send(steps)
                }.store(in: &subscriptions)
        }
    }
    var week = DateRange() {
        didSet{
            getDataForSpecificPeriodTime(selectedDate: week.startDate, activity: selectedAcvitityType, period: .oneDay)
                .sink { [weak self] steps in
                    print("Downlaoded steps: \(steps)")
                    self?.dataForOneWeek.send(steps)
                }.store(in: &subscriptions)
        }
    }
    var year = DateRange() {
        didSet{
            getDataForSpecificPeriodTime(selectedDate: year.startDate, activity: selectedAcvitityType, period: .oneMonth)
                .sink { [weak self] steps in
                    print("Downlaoded steps: \(steps)")
                    self?.dataForOneYear.send(steps)
                }.store(in: &subscriptions)
        }
    }
    

    
    //MARK: - Get Date Range
    func getDayRange(forSelectedDate: Date) {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: forSelectedDate)
        var components = DateComponents().forPeriod(period: .oneDay)
        let endWeek = Calendar.current.date(byAdding: components, to: startDay)!
        print("GetDayRange ustawiony na date:", startDay)
        day.startDate = startDay
        //week.endDate = endWeek
    }
    func getWeekRange(forSelectedDate: Date) {
        let startWeek = forSelectedDate.startOfWeek()
        var components = DateComponents()
        components.day = 6
        let endWeek = Calendar.current.date(byAdding: components, to: startWeek)!
        week.startDate = startWeek
        //week.endDate = endWeek

    }
    func getYearRange(forSelectedDate: Date) {
        let startMonth = forSelectedDate.startOfYear
        var components = DateComponents()
        components.year = 1
        print("GetYearRange ustawiony na date:", startMonth)
        year.startDate = startMonth
        //week.endDate = endWeek
        
    }
    
    //MARK: - Get Data For Specific Period Time
    func getDataForSpecificPeriodTime(selectedDate: Date, activity: activityType, period: DateComponents.Periods) -> Future<[Date:Double],Never>{
        Future { promise in
            var components = DateComponents()
            var data = [Date:Double]()
            var max: Int
            //let startDate = Calendar.current.startOfDay(for: Date())
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
                                print("AKTUALNA TABLICA:", steps, "dla daty: ", checkDay)
                                data[checkDay] = steps
                                myGroup.leave()
                            }.store(in: &self.subscriptions)
                        break
                    case .distance:
                        self.healthKit.getSteps(selectedDay: checkDay, pir: period)
                            .sink { steps in
                                print("AKTUALNA TABLICA:", steps, "dla daty: ", checkDay)
                                data[checkDay] = steps
                                myGroup.leave()
                            }.store(in: &self.subscriptions)
                        break
                    default:
                        break
                    }
                }
            myGroup.notify(queue:.main){
                promise(.success(data))
            }
            
        }
    }
    
}
