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

    
    //MARK: - Outlets
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!

    @IBOutlet weak var dayHistoryLineChart: LineChartView!
    @IBOutlet weak var weekHistoryLineChart: LineChartView!
    @IBOutlet weak var monthsHistoryLineChart: LineChartView!


    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var monthsLabel: UILabel!


    @IBOutlet weak var dayBottomSection: customViewDetails!
    @IBOutlet weak var monthBottomSection: customViewDetails!
    @IBOutlet weak var yearsBottomSection: customViewDetails!

    //MARK: - References
    let viewModel = HistoryViewModel()
    
    var subscriptions = Set<AnyCancellable>()
    func fetchData(){
        viewModel.getDayRange(forSelectedDate: Date())
        viewModel.getWeekRange(forSelectedDate: Date())
        viewModel.getYearRange(forSelectedDate: Date())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.allowsMultipleSelection = false
        weekHistoryLineChart.noDataText = "Brak danych"
        dayHistoryLineChart.noDataText = "Brak danych"

        fetchData()

        mainView.setGradientBackground(view: mainView)
        
        viewModel.dataForOneDay
            .sink {[weak self] data in
                self?.setDayHeading(selectedDate: (self?.viewModel.day.startDate)!)
                self?.setupCharts(stepsTab: data, for: self!.dayHistoryLineChart)
                //self?.dayHistoryLineSetup(stepsTab: data)
                self?.dayBottomSectionSetup(stepsTab: data)
            }.store(in: &subscriptions)
        
        viewModel.dataForOneWeek
            .sink {[weak self] data in
                self?.setWeekHeading(selectedDate: (self?.viewModel.week.startDate)!)
                self?.setupCharts(stepsTab: data, for: self!.weekHistoryLineChart)
                self?.weekBottomSectionSetup(stepsTab: data)
            }.store(in: &subscriptions)
        
        viewModel.dataForOneYear
            .sink {[weak self] data in
                self?.setYearHeading(selectedDate: (self?.viewModel.year.startDate)!)
                self?.setupCharts(stepsTab: data, for: self!.monthsHistoryLineChart)
                self?.yearBottomSectionSetup(stepsTab: data)
            }.store(in: &subscriptions)

    }


    //MARK: - Category Collection View Configuration
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
        fetchData()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = categoryCollectionView.cellForItem(at: indexPath) as! categoryCell
        cell.isSelected = false
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = categoryCollectionView.frame.width
        let cellWidth = (collectionWidth / 3) - 13.3
        
        return CGSize(width: cellWidth, height: 50)
    }
    
    // MARK: - Buttons Setup
    @IBAction func dayButtonBack(_ sender: Any) {
        viewModel.dayButtonBackDidTapped()
    }
    @IBAction func dayButtonNext(_ sender: Any) {
        viewModel.dayButtonNextDidTapped()
    }
    @IBAction func weekButtonBack(_ sender: Any) {
        viewModel.weekButtonBackDidTapped()
    }
    @IBAction func weekButtonNext(_ sender: Any) {
        viewModel.weekButtonNextDidTapped()
    }
    @IBAction func backYearButton(_ sender: Any) {
        viewModel.yearButtonBackDidTapped()
    }
    @IBAction func nextYearButton(_ sender: Any) {
        viewModel.yearButtonNextDidTapped()
    }
    
    // MARK: - Heads sections setup
    func setDayHeading(selectedDate: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.locale = Locale(identifier: "pl_PL")
        let startWeek = dateFormatter.string(from: selectedDate)
        self.dayLabel.text = (startWeek)
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
    
    func setYearHeading(selectedDate: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        dateFormatter.locale = Locale(identifier: "pl_PL")
        let startMonth = dateFormatter.string(from: selectedDate)
        self.monthsLabel.text = (startMonth)
    }
    
    // MARK: - Bottom sections setup
    func dayBottomSectionSetup(stepsTab: [Date:Double]){
        var sumSteps = 0.0
        var aveSteps = 0.0
        for step in stepsTab {
            if step.key < Date(){
                sumSteps += step.value
            }
        }
        aveSteps = sumSteps/Double(stepsTab.count)
        dayBottomSection.averageLabel.text = String(format: "%.0f",aveSteps)
        dayBottomSection.sumLabel.text = String (format: "%.0f",sumSteps)
    }
    
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
    
    // MARK: - Charts setup
    func setupCharts(stepsTab: [Date:Double], for Chart: LineChartView){
        let sortedByDates = stepsTab.sorted{$1.key > $0.key}
        print("Sorted By dates: \(sortedByDates)")
        var entries = [ChartDataEntry]()
        for (index, hours) in sortedByDates.enumerated(){
            let roundedValue = round(hours.value * 10) / 10
            let entry = (ChartDataEntry(x: Double(index), y: roundedValue))
            entries.append(entry)
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: "Test")
        let data = LineChartData(dataSets: [dataSet])
        
        Chart.data = data
        

        Chart.pinchZoomEnabled = false
        Chart.scaleYEnabled = false
        Chart.legend.enabled = false

        
        
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
        
        let leftAxis = Chart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = UIColor.white
        
        let xAxis = Chart.xAxis
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = UIColor.white
        xAxis.granularity = 1
        xAxis.forceLabelsEnabled = true
        xAxis.labelPosition = .bottom

        Chart.rightAxis.enabled = false

        var xAxisValue = [String]()
        
        switch Chart {
        case dayHistoryLineChart:
            xAxisValue = ["00:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00"]
            xAxis.labelCount = 24
            Chart.dragEnabled = true
            Chart.setScaleEnabled(true)
            Chart.setVisibleXRangeMaximum(10)
            Chart.setVisibleXRangeMinimum(5)
        case weekHistoryLineChart:
            xAxisValue = ["Pn", "Wt", "Śr", "Czw", "Pt", "Sob", "Ndź"]
            xAxis.labelCount = 7
            Chart.dragEnabled = false
            Chart.setScaleEnabled(false)
        case monthsHistoryLineChart:
            xAxisValue = ["Sty","Lut","Marz","Kw","Maj","Cze","Lip","Sie","Wrz","Paź","Lis","Gru"]
            xAxis.axisMaxLabels = 7
            xAxis.labelCount = 12
            Chart.dragEnabled = true
            Chart.setScaleEnabled(false)
            Chart.setVisibleXRangeMinimum(12)
            Chart.setVisibleXRangeMaximum(12)
            
        default:
            break
        }
        xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisValue)
        
        Chart.notifyDataSetChanged()
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
