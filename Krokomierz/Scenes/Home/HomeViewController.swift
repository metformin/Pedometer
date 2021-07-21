//
//  ViewController.swift
//  Krokomierz
//
//  Created by Darek on 27/12/2020.
//

import UIKit
import HealthKit
import CoreMotion

public var goalSteps:Double = getGoalStepsAmount()

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet var mainView: UIView!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCell", for: indexPath) as! activityCollectionViewCell
        switch (indexPath.row) {
        case 0:
            cell.imageActivity.image = UIImage(named: "distanceIco")
            cell.counterLabel.text = String(format: "%.2f",distanceCounter/1000)
            cell.counterUnitsLabel.text = "km"
            break
            
        case 1:
            cell.imageActivity.image = UIImage(named: "distanceIco")
            cell.counterLabel.text = String(energyBurnedCounter)
            cell.counterUnitsLabel.text = "kcal"
            break
            
        case 2:
            cell.imageActivity.image = UIImage(named: "distanceIco")
            cell.counterLabel.text = String(floorCounter)
            cell.counterUnitsLabel.text = "piętro"
            break
        case 3:
            cell.imageActivity.image = UIImage(named: "distanceIco")
            cell.counterLabel.text = String(activeTimeCounter)
            cell.counterUnitsLabel.text = "minut"
            break
        default:
            break
        }

        //cell.backgroundActivity.getRounded(cornerRadius: 10)

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let collectionWidth = collectionView.frame.width
        let cellWidth = (collectionWidth / 3) - 13.3
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    let pedometer = CMPedometer()
    
    @IBOutlet var collectionView: UICollectionView!
    private var distanceCounter:Double = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    private var energyBurnedCounter:Double = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    private var activeTimeCounter:Double = 0 {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet var goalStepsPercentsLabel: UILabel!
    private var stepsCounter:Int = 0 {
        didSet {
            let percent:Double = Double(stepsCounter) / goalSteps
            let percentToInt:Int =  Int(percent * 100)
            goalStepsPercentsLabel.text = String(percentToInt) + "%"
            
            self.stepperBar.progress = CGFloat(Double(stepsCounter)/goalSteps)

            
            goalStepsCounterLabel.text = String(stepsCounter) + " z " + String(Int(goalSteps)) + " kroków"

        }
    }
    private var floorCounter:Int = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    @IBOutlet var goalStepsCounterLabel: UILabel!
    
    @IBOutlet weak var stepperBar: CircularProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        enableHealthStore()
        startUpdateStepsLive()
        mainView.setGradientBackground(view: mainView)
        //let setGoalSteps:Double = getGoalStepsAmount() ?? 10000.0
        
        //goalSteps = getGoalStepsAmount()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.goalStepsPercentsLabel.text = "xD"        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            self.stepperBar.progress = 0.1        }
    }
    
    
    // MARK: CoreMotion:

    
    private func startUpdateStepsLive(){
        let calendar = Calendar.current
        pedometer.startUpdates(from: calendar.startOfDay(for: Date())) { (data, error) in
            guard let pedometerData = data else {return}
            DispatchQueue.main.async {
                self.stepsCounter = pedometerData.numberOfSteps.intValue
                self.distanceCounter = pedometerData.distance?.doubleValue ?? 0.0
                self.floorCounter = pedometerData.floorsAscended as! Int
                
                
            }
        }
    }
    
    
    
    // MARK: Health Kit

    func getTodayStepsCollection(completion: @escaping (Double) -> Void){
        let healthStore = HKHealthStore()

        let stepQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.startOfDay(for: Date())
        //let predictate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery (quantityType: stepQuantityType,
                                      quantitySamplePredicate: nil,
                                      options: [.cumulativeSum],
                                      anchorDate: startDate,
                                      intervalComponents: interval)
        
        

        
        query.statisticsUpdateHandler = {
            query, statistics, statisticsCollection, error in

            // If new statistics are available
            if let sum = statistics?.sumQuantity() {
                let resultCount = sum.doubleValue(for: HKUnit.count())
                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            } // end if
        }
        query.initialResultsHandler = { _, result, error in
                var resultCount = 0.0
                result!.enumerateStatistics(from: startDate, to: Date()) { statistics, _ in

                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    resultCount = sum.doubleValue(for: HKUnit.count())
                } // end if

                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            }
        }
        healthStore.execute(query)

    }
    
    func getTodaySteps(completion: @escaping (Double) -> Void){
        let healthStore = HKHealthStore()

        let stepQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predictate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepQuantityType,
                                      quantitySamplePredicate: predictate,
                                      options: .cumulativeSum) { _, result,_ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))

        }
        healthStore.execute(query)
    }
    
    func getTodayDistanceWalkingRunning(completion: @escaping (Double) -> Void){
        let healthStore = HKHealthStore()

        let distanceWalkingRunningQuantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predictate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceWalkingRunningQuantityType,
                                      quantitySamplePredicate: predictate,
                                      options: .cumulativeSum) { _, result,_ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.meterUnit(with: .kilo)))

        }
        healthStore.execute(query)
    }
    func getTodayActiveEnergyBurned(completion: @escaping (Double) -> Void){
        let healthStore = HKHealthStore()

        let activeEnergyBurnedQuantityType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predictate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: activeEnergyBurnedQuantityType,
                                      quantitySamplePredicate: predictate,
                                      options: .cumulativeSum) { _, result,_ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.kilocalorie()))

        }
        healthStore.execute(query)
    }
    func getTodayActiveTime(completion: @escaping (Double) -> Void){
        let healthStore = HKHealthStore()

        let activeTimeQuantityType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predictate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: activeTimeQuantityType,
                                      quantitySamplePredicate: predictate,
                                      options: .cumulativeSum) { _, result,_ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.minute()))

        }
        healthStore.execute(query)
    }
    func enableHealthStore(){
        if HKHealthStore.isHealthDataAvailable(){
            let healthStore = HKHealthStore()
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
            let allTypes2 = Set([HKObjectType.workoutType(),
                                stepQuantityType,
                                distanceWalkingRunningQuantityType,
                                activeEnergyBurned
                                ])
            healthStore.requestAuthorization(toShare: allTypes2, read: allTypes) { (success, error) in
                if !success{
                    print("DEBUG: HealthStore auth failed(read)")
                } else {
                    print("DEBUG: HealthStore auth successed(read)")


                    self.getTodayActiveTime { (Double) in

                        DispatchQueue.main.async {
                            print("Time: ", Double)
                        }
                    }
                    self.getTodaySteps { (Double) in

                        DispatchQueue.main.async {
                            print("Steps: ", Double)
                        }
                    }


                
            }
            let authStatus = healthStore.authorizationStatus(for: stepQuantityType)
            switch authStatus {
            case .sharingDenied:
                print("DEBUG: Auth status sharing denied(save)")
            case .sharingAuthorized:
                print("DEBUG: Auth status sharing authorized(save)")
            default:
                print("Not determinated")
            }
            
        }
       }


    }
}

class activityCollectionViewCell: UICollectionViewCell {
    @IBOutlet var backgroundActivity: UIView!
    @IBOutlet var imageActivity: UIImageView!
    @IBOutlet var counterUnitsLabel: UILabel!
    
    @IBOutlet var counterLabel: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundActivity.getRounded(cornerRadius: 10)
        
    }
    
}
