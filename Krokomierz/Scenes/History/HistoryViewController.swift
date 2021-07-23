//
//  HistoryViewController.swift
//  Krokomierz
//
//  Created by Darek on 17/01/2021.
//

import UIKit
import Charts
import HealthKit
import Combine


class historyViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    let viewModel = HistoryViewModel()
    var subscriptions = Set<AnyCancellable>()

    @IBOutlet var mainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.allowsMultipleSelection = false
//        weekHistoryLineChart.noDataText = "Brak danych"
        dayHistoryLineChart.noDataText = "Brak danych"

        viewModel.getDayRange(forSelectedDate: Date())
        viewModel.getWeekRange(forSelectedDate: Date())
        viewModel.getYearRange(forSelectedDate: Date())

        //getWeekRange(forSelectedDate: Date())
        
        //getMonthRange(forSelectedDate: Date())
        
        mainView.setGradientBackground(view: mainView)
        
        viewModel.dataForOneDay
            .sink {[weak self] data in
                print("dataForOneday Completed")
                self?.setDayHeading(selectedDate: (self?.viewModel.day.startDate)!)
                self?.dayHistoryLineSetup(stepsTab: data)
                self?.dayBottomSectionSetup(stepsTab: data)
            }.store(in: &subscriptions)
        
        viewModel.dataForOneWeek
            .sink {[weak self] data in
                print("dataForOneWeek Completed")
                self?.setWeekHeading(selectedDate: (self?.viewModel.week.startDate)!)
                self?.weekHistoryLineSetup(stepsTab: data)
                self?.weekBottomSectionSetup(stepsTab: data)
            }.store(in: &subscriptions)
        
        viewModel.dataForOneYear
            .sink {[weak self] data in
                print("dataForOneYear Completed")
                self?.setYearHeading(selectedDate: (self?.viewModel.year.startDate)!)
                self?.yearHistoryLineSetup(stepsTab: data)
                self?.yearBottomSectionSetup(stepsTab: data)
            }.store(in: &subscriptions)

    }
    // MARK: Category collection:
    enum categories {
        case steps, distance, calories
    }
//    var selCat: Activity.activityType = .steps{
//        didSet{
//            getDayRange(forSelectedDate: Date())
//            getMonthRange(forSelectedDate: Date())
//            getWeekRange(forSelectedDate: Date())
//        }
//    }
    
//    var selectedCategory: categories = .steps{
//        didSet{
////            getDayRange(forSelectedDate: Date())
////            getMonthRange(forSelectedDate: Date())
////            getWeekRange(forSelectedDate: Date())
//
//        }
//    }
    @IBOutlet weak var categoryCollectionView: UICollectionView!

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! categoryCell
        
        switch (indexPath.row) {
        case 0:
            cell.nameCategory.text = "Kroki"
            cell.isSelected = true
            categoryCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            break
        case 1:
            cell.nameCategory.text = "Dystans"
            break
        case 2:
            cell.nameCategory.text = "Kalorie"
            break
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let firstCell = IndexPath(item: 0, section: 0)
//        if indexPath != firstCell {
//            self.collectionView(categoryCollectionView, didDeselectItemAt: IndexPath(row: 0, section: 0))
//        }
        
        let cell = categoryCollectionView.cellForItem(at: indexPath) as! categoryCell
        cell.isSelected = true
        
        switch (indexPath.row) {
        case 0:
            viewModel.selectedAcvitityType = .steps
            break
        case 1:
            viewModel.selectedAcvitityType = .distance
            break
        case 2:
            viewModel.selectedAcvitityType = .calories
            break
        default:
            break
        }
        print(indexPath.row, " selected")

    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = categoryCollectionView.cellForItem(at: indexPath) as! categoryCell
        cell.isSelected = false
        print(indexPath.row , " deselected")

    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = categoryCollectionView.frame.width
        let cellWidth = (collectionWidth / 3) - 13.3
        
        
        return CGSize(width: cellWidth, height: 50)
    }
    
    // MARK: General charts setup:
    struct DateRange {
        var startDate: Date
        var endDate: Date?
        
        init(){
            startDate = Date()
        }
    }
    // MARK: Day Setup
    @IBOutlet weak var dayHistoryLineChart: LineChartView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBAction func dayButtonBack(_ sender: Any) {
        var components = DateComponents()
        components.day = -1
//        let backWeek = Calendar.current.date(byAdding: components, to: day.startDate)!
//        getDayRange(forSelectedDate: backWeek)
    }
    @IBAction func dayButtonNext(_ sender: Any) {
        var components = DateComponents()
        components.day = 1
//        let backWeek = Calendar.current.date(byAdding: components, to: day.startDate)!
//        getDayRange(forSelectedDate: backWeek)
    }
    
    
//    var day = DateRange() {
//        didSet{
//            getDayData(selectedDate: day.startDate, category: selectedCategory) { (stepsTab: [Date:Double]) in
//                    print("Pobrana tablica dla jednego dnia:", stepsTab)
//                self.dayHistoryLineSetup(stepsTab: stepsTab)
//                self.setDayHeading(selectedDate: self.day.startDate)
//                self.dayBottomSectionSetup(stepsTab: stepsTab)
//            }
//        }
//    }
    
    func setDayHeading(selectedDate: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.locale = Locale(identifier: "pl_PL")
        let startWeek = dateFormatter.string(from: selectedDate)
        self.dayLabel.text = (startWeek)
    }
    
    func getDayRange(forSelectedDate: Date) {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: forSelectedDate)
        var components = DateComponents()
        components.day = 1
        let endWeek = Calendar.current.date(byAdding: components, to: startDay)!
        print("GetDayRange ustawiony na date:", startDay)
        //day.startDate = startDay
        //week.endDate = endWeek
    }
    //Downloads data for whole day:
    func getDayData(selectedDate: Date, category: categories, completion: @escaping ([Date:Double]) -> Void) {
        var data = [Date:Double]()
        //let startDate = Calendar.current.startOfDay(for: Date())
        var components = DateComponents()
  
        
        let myGroup = DispatchGroup()

        
        
            for i in 0...23{
                myGroup.enter()
                components.hour = i
                let checkDay = Calendar.current.date(byAdding: components, to: selectedDate)!
                switch category {
                case .steps:
                    self.getSteps(forPeriod: .oneHour, selectedDay: checkDay) { (steps) in
                        DispatchQueue.main.async {
                            print("AKTUALNA TABLICA:", steps, "dla daty: ", checkDay)
                            data[checkDay] = steps
                            myGroup.leave()
                        }
                    }
                    break
                case .distance:
                    self.getDistance(forPeriod: .oneHour, selectedDay: checkDay) { (steps) in
                        DispatchQueue.main.async {
                            print("AKTUALNA TABLICA:", steps, "dla daty: ", checkDay)
                            data[checkDay] = steps
                            myGroup.leave()
                        }
                    }
                    break
                default:
                    break
                }
            }
        myGroup.notify(queue:.main){
            completion(data)
        }
        

    }
    func dayHistoryLineSetup(stepsTab: [Date:Double]){
        let sortedByDates = stepsTab.sorted{$1.key > $0.key}
        print("Sorted By dates: \(sortedByDates)")
        var entries = [ChartDataEntry]()
        for (index, hours) in sortedByDates.enumerated(){
            let entry = (ChartDataEntry(x: Double(index), y: hours.value))
            entries.append(entry)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "Test")

        let data = LineChartData(dataSets: [dataSet])
        dayHistoryLineChart.data = data
        dayHistoryLineChart.dragEnabled = true
        dayHistoryLineChart.setScaleEnabled(true)
        dayHistoryLineChart.setVisibleXRangeMaximum(10)
        dayHistoryLineChart.setVisibleXRangeMinimum(5)

        //All other additions to this function will go here
        let gradColors = [UIColor.green.cgColor, UIColor.clear.cgColor]
        let colorLocations:[CGFloat] = [0.0, 1.0]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradColors as CFArray, locations: colorLocations) {
            dataSet.fill = Fill(linearGradient: gradient, angle: 270.0)
        }
        dataSet.mode = .horizontalBezier
        dataSet.cubicIntensity = 0.2
        dataSet.fillAlpha = 1
        dataSet.drawCirclesEnabled = false
        dataSet.drawFilledEnabled = true
        dataSet.valueTextColor = UIColor.white
        dayHistoryLineChart.pinchZoomEnabled = false
        dayHistoryLineChart.scaleYEnabled = false
        dayHistoryLineChart.scaleXEnabled = true


        dayHistoryLineChart.legend.enabled = false


        let leftAxis = dayHistoryLineChart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = UIColor.white



        let xAxis = dayHistoryLineChart.xAxis
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = UIColor.white


        let hours = ["00:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00"]
        xAxis.valueFormatter = IndexAxisValueFormatter(values:hours)
        xAxis.granularity = 1
        xAxis.forceLabelsEnabled = true
        xAxis.labelCount = 24
        xAxis.labelPosition = .bottom





        dayHistoryLineChart.rightAxis.enabled = false

        //This must stay at end of function
        //dayHistoryLineChart.notifyDataSetChanged()
    }

    // Day setup bottom section:
    @IBOutlet weak var dayBottomSection: customViewDetails!

    func dayBottomSectionSetup(stepsTab: [Date:Double]){
        var sumSteps = 0.0
        var aveSteps = 0.0
        for step in stepsTab {
            if step.key < Date(){
                sumSteps += step.value
            } else {
                print("Kroki nie zostaną dodane do sumy: ", step.value, " poniewaz data jest powyzej terazniejszosci: ", step.key)
            }
        }
        aveSteps = sumSteps/Double(stepsTab.count)
        dayBottomSection.averageLabel.text = String(format: "%.0f",aveSteps)
        dayBottomSection.sumLabel.text = String (format: "%.0f",sumSteps)
    }


    // MARK: Week Setup
    @IBOutlet weak var weekHistoryLineChart: LineChartView!
    @IBOutlet weak var weekLabel: UILabel!
    @IBAction func weekButtonBack(_ sender: Any) {
        var components = DateComponents()
        components.day = -1
//        let backWeek = Calendar.current.date(byAdding: components, to: week.startDate)!
//        getWeekRange(forSelectedDate: backWeek)
    }
    @IBAction func weekButtonNext(_ sender: Any) {
        var components = DateComponents()
        components.day = 7
//        let backWeek = Calendar.current.date(byAdding: components, to: week.startDate)!
//        getWeekRange(forSelectedDate: backWeek)
    }


    func setWeekHeading(selectedDate: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.locale = Locale(identifier: "pl_PL")
        let startWeek = dateFormatter.string(from: selectedDate.startOfWeek())
        var components = DateComponents()
        components.day = 6
        let endWeek = dateFormatter.string(from:Calendar.current.date(byAdding: components, to: selectedDate.startOfWeek())!)
        self.weekLabel.text = (startWeek + " - " + endWeek)
    }
//    func getWeekRange(forSelectedDate: Date) {
//        let startWeek = forSelectedDate.startOfWeek()
//        var components = DateComponents()
//        components.day = 6
//        let endWeek = Calendar.current.date(byAdding: components, to: startWeek)!
//        week.startDate = startWeek
//        //week.endDate = endWeek
//
//    }

    func weekHistoryLineSetup(stepsTab: [Date:Double]){



        let sortedByDates = stepsTab.sorted{$1.key > $0.key}
        var entries = [ChartDataEntry]()
        for (index, days) in sortedByDates.enumerated(){
            let entry = (ChartDataEntry(x: Double(index), y: days.value))
            entries.append(entry)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "Test")
        dataSet.valueTextColor = UIColor.white

        let data = LineChartData(dataSets: [dataSet])
        weekHistoryLineChart.data = data
        weekHistoryLineChart.dragEnabled = false
        weekHistoryLineChart.setScaleEnabled(false)

        //All other additions to this function will go here
        let gradColors = [UIColor.green.cgColor, UIColor.clear.cgColor]
        let colorLocations:[CGFloat] = [0.0, 1.0]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradColors as CFArray, locations: colorLocations) {
            dataSet.fill = Fill(linearGradient: gradient, angle: 270.0)
        }
        dataSet.mode = .horizontalBezier
        dataSet.cubicIntensity = 0.2
        dataSet.fillAlpha = 1
        dataSet.drawCirclesEnabled = false
        dataSet.drawFilledEnabled = true

        weekHistoryLineChart.pinchZoomEnabled = false


        weekHistoryLineChart.legend.enabled = false


        let leftAxis = weekHistoryLineChart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = UIColor.white


        let xAxis = weekHistoryLineChart.xAxis
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        let days = ["Pn", "Wt", "Śr", "Czw", "Pt", "Sob", "Ndź"]
        xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
        xAxis.granularity = 1
        xAxis.forceLabelsEnabled = true
        xAxis.labelCount = 7
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = UIColor.white




        weekHistoryLineChart.rightAxis.enabled = false

        //This must stay at end of function
        weekHistoryLineChart.notifyDataSetChanged()
    }
    //Downloads data for whole week:
    func getWeekData(selectedDate: Date, category: categories, completion: @escaping ([Date:Double]) -> Void) {
        var data = [Date:Double]()
        //let startDate = Calendar.current.startOfDay(for: Date())
        var components = DateComponents()
  
        
        let myGroup = DispatchGroup()

        
        
            for i in 0...6{
                myGroup.enter()
                components.day = i
                let checkDay = Calendar.current.date(byAdding: components, to: selectedDate)!
                switch category {
                case .steps:
                    self.getSteps(forPeriod:.oneDay, selectedDay: checkDay) { (steps) in
                        DispatchQueue.main.async {
                            print("AKTUALNA TABLICA:", steps)
                            data[checkDay] = steps
                            myGroup.leave()
                        }
                    }
                    break
                case .distance:
                    self.getDistance(forPeriod:.oneDay, selectedDay: checkDay) { (steps) in
                        DispatchQueue.main.async {
                            print("AKTUALNA TABLICA:", steps)
                            data[checkDay] = steps
                            myGroup.leave()
                        }
                    }
                    break
                case .calories:
                    break
                }
            }
        myGroup.notify(queue:.main){
            completion(data)
        }
        

    }
    // Months setup bottom section:
    @IBOutlet weak var monthBottomSection: customViewDetails!
    
    func weekBottomSectionSetup(stepsTab: [Date:Double]){
        var sumSteps = 0.0
        var aveSteps = 0.0
        for step in stepsTab.values {
            sumSteps += step
        }
        aveSteps = sumSteps/Double(stepsTab.count)
        monthBottomSection.averageLabel.text = String(format: "%.0f",aveSteps)
        monthBottomSection.sumLabel.text = String (format: "%.0f",sumSteps)
        
    }
    
    
    // MARK: Year Setup
    @IBOutlet weak var monthsHistoryLineChart: LineChartView!
    @IBOutlet weak var monthsLabel: UILabel!
    @IBAction func backYearButton(_ sender: Any) {
        var components = DateComponents()
        components.year = -1
        let backYear = Calendar.current.date(byAdding: components, to: year.startDate)!
        getMonthRange(forSelectedDate: backYear)
    }
    @IBAction func nextYearButton(_ sender: Any) {
        var components = DateComponents()
        components.year = 1
        let nextYear = Calendar.current.date(byAdding: components, to: year.startDate)!
        getMonthRange(forSelectedDate: nextYear)
    }
    var year = DateRange() {
        didSet{
//            getMonthData(selectedDate: year.startDate, category: selectedCategory) { (stepsTab: [Date:Double]) in
//                    print("Pobrana tablica:", stepsTab)
//                self.yearHistoryLineSetup(stepsTab: stepsTab)
//                self.setYearHeading(selectedDate: self.year.startDate)
//                self.yearsBottomSectionSetup(stepsTab: stepsTab)
//
//            }
        }
    }
    
    func setYearHeading(selectedDate: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        dateFormatter.locale = Locale(identifier: "pl_PL")
        let startMonth = dateFormatter.string(from: selectedDate)

        self.monthsLabel.text = (startMonth)
    }
    
    func getMonthRange(forSelectedDate: Date) {
        let startMonth = forSelectedDate.startOfYear
        var components = DateComponents()
        components.year = 1
        print("GetYearRange ustawiony na date:", startMonth)
        year.startDate = startMonth
        //week.endDate = endWeek
        
    }
    //Downloads data for whole month:
    func getMonthData(selectedDate: Date, category: categories, completion: @escaping ([Date:Double]) -> Void) {
        var data = [Date:Double]()
                
        var components = DateComponents()
        let myGroup = DispatchGroup()

        for i in 0...11{
                myGroup.enter()
                components.month = i
                let checkMonth = Calendar.current.date(byAdding: components, to: selectedDate)!
            switch category {
            case .steps:
                self.getSteps(forPeriod: .oneMonth, selectedDay: checkMonth) { (steps) in
                    DispatchQueue.main.async {
                        print("AKTUALNA TABLICA:", steps, "dla daty: ", checkMonth)
                        data[checkMonth] = steps
                        myGroup.leave()
                    }
                }
                break
            case .distance:
                self.getDistance(forPeriod: .oneMonth, selectedDay: checkMonth) { (steps) in
                    DispatchQueue.main.async {
                        print("AKTUALNA TABLICA:", steps, "dla daty: ", checkMonth)
                        data[checkMonth] = steps
                        myGroup.leave()
                    }
                }
                break
            case .calories:
                break
            }
        }
        myGroup.notify(queue:.main){
            completion(data)
        }
        

    }
    func yearHistoryLineSetup(stepsTab: [Date:Double]){


        
        let sortedByDates = stepsTab.sorted{$1.key > $0.key}
        var entries = [ChartDataEntry]()
        for (index, months) in sortedByDates.enumerated(){
            let entry = (ChartDataEntry(x: Double(index), y: months.value))
            entries.append(entry)
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: "Test")
        dataSet.valueTextColor = UIColor.white

        
        let data = LineChartData(dataSets: [dataSet])
        monthsHistoryLineChart.data = data
        monthsHistoryLineChart.dragEnabled = true
        monthsHistoryLineChart.setScaleEnabled(false)
        monthsHistoryLineChart.setVisibleXRangeMinimum(12)
        monthsHistoryLineChart.setVisibleXRangeMaximum(12)


        //All other additions to this function will go here
        let gradColors = [UIColor.green.cgColor, UIColor.clear.cgColor]
        let colorLocations:[CGFloat] = [0.0, 1.0]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradColors as CFArray, locations: colorLocations) {
            dataSet.fill = Fill(linearGradient: gradient, angle: 270.0)
        }
        dataSet.mode = .horizontalBezier
        dataSet.cubicIntensity = 0.2
        dataSet.fillAlpha = 1
        dataSet.drawCirclesEnabled = false
        dataSet.drawFilledEnabled = true
        
        monthsHistoryLineChart.pinchZoomEnabled = false
        monthsHistoryLineChart.scaleYEnabled = false
        monthsHistoryLineChart.scaleXEnabled = false

        
        monthsHistoryLineChart.legend.enabled = false
        
        
        let leftAxis = monthsHistoryLineChart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = UIColor.white
        
        
        let xAxis = monthsHistoryLineChart.xAxis
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = UIColor.white
        
        let months = ["Sty","Lut","Marz","Kw","Maj","Cze","Lip","Sie","Wrz","Paź","Lis","Gru"]
        xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        xAxis.granularity = 1
        xAxis.forceLabelsEnabled = true
        xAxis.labelCount = 12
        xAxis.labelPosition = .bottom
        xAxis.axisMaxLabels = 7
        


        
        monthsHistoryLineChart.rightAxis.enabled = false

        //This must stay at end of function
        monthsHistoryLineChart.notifyDataSetChanged()
    }
    //Years setup bottom section:
    
    
    @IBOutlet weak var yearsBottomSection: customViewDetails!
    
    func yearBottomSectionSetup(stepsTab: [Date:Double]){
        var sumSteps = 0.0
        var aveSteps = 0.0
        for step in stepsTab.values {
            sumSteps += step
        }
        aveSteps = sumSteps/Double(stepsTab.count)
        yearsBottomSection.averageLabel.text = String(format: "%.0f",aveSteps)
        yearsBottomSection.sumLabel.text = String (format: "%.0f",sumSteps)
        
        
    }

    
    // MARK: HealthStore
    enum Periods{
        case oneHour, oneDay, oneMonth
    }
    func enableHealthStore(){
        if HKHealthStore.isHealthDataAvailable(){
            let healthStore = HKHealthStore()
            let stepQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
            let distanceWalkingRunningQuantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
            let appleExerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!

            let allTypes = Set([HKObjectType.workoutType(),
                                stepQuantityType,
                                distanceWalkingRunningQuantityType,
                                activeEnergyBurned,
                                appleExerciseTime
                                ])

            healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
                if !success{
                    print("DEBUG: HealthStore auth failed(read)")
                } else {
                    print("DEBUG: HealthStore auth successed(read)")


    


                
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
    func getSteps(forPeriod: Periods, selectedDay:Date, completion: @escaping (Double) -> Void){
        let healthStore = HKHealthStore()

        let stepQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startDate = selectedDay
        
        var components = DateComponents()
        switch forPeriod {
        case .oneHour:
            components.hour = 1
            break
        case .oneDay:
            components.day = 1
            components.second = 1
            break
        case .oneMonth:
            components.month = 1
            break
        }
        let endDate = Calendar.current.date(byAdding: components, to: startDate)!
        let predictate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepQuantityType,
                                      quantitySamplePredicate: predictate,
                                      options: .cumulativeSum) { _, result,_ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
            print("RES SUC:\(result)")


        }
        healthStore.execute(query)
    }


    
    func getDistance(forPeriod: Periods,selectedDay:Date, completion: @escaping (Double) -> Void){
        let healthStore = HKHealthStore()

        let stepQuantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let startDate = selectedDay
        

        var components = DateComponents()
        switch forPeriod {
        case .oneHour:
            components.hour = 1
            break
        case .oneDay:
            components.day = 1
            components.second = 1
            break
        case .oneMonth:
            components.month = 1
            break
        }
        let endDate = Calendar.current.date(byAdding: components, to: startDate)!
        let predictate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepQuantityType,
                                      quantitySamplePredicate: predictate,
                                      options: .cumulativeSum) { _, result,_ in
            guard let result = result, let sum = result.sumQuantity() else {

                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.meter()))

        }
        healthStore.execute(query)
    }
    
}

class categoryCell: UICollectionViewCell{
    @IBOutlet weak var mainBackgroundCategoryCell: UIView!
    @IBOutlet weak var nameCategory: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        mainBackgroundCategoryCell.getRounded(cornerRadius: 10)
        mainBackgroundCategoryCell.layer.borderWidth = 1
        mainBackgroundCategoryCell.layer.borderColor = UIColor.green.cgColor
    }
    override var isSelected: Bool
    {
        didSet
        {
            if isSelected == true {
                mainBackgroundCategoryCell.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1 )
                nameCategory.textColor = UIColor.white
            } else {
                mainBackgroundCategoryCell.backgroundColor = UIColor.clear
                nameCategory.textColor = UIColor.green
            }
        }
    }
    
}
