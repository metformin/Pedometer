//
//  ViewController.swift
//  Krokomierz
//
//  Created by Darek on 27/12/2020.
//

import UIKit
import HealthKit
import CoreMotion
import Combine

public var goalSteps:Double = getGoalStepsAmount()

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Outlets
    @IBOutlet var mainView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var goalStepsCounterLabel: UILabel!
    @IBOutlet var goalStepsPercentsLabel: UILabel!
    @IBOutlet weak var stepperBar: CircularProgressView!
    
    //MARK: - References
    let viewModel = HomeViewModel()
    let historyViewModel = HistoryViewModel()
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        startUpdateStepsLive()
        mainView.setGradientBackground(view: mainView)
        viewModel.setupStartUpdateStepsLive()
        
        
        
        //Testy:
        historyViewModel.getDayRange(forSelectedDate: Date())
    }
    //MARK: - Collection View Setup
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCell", for: indexPath) as! activityCollectionViewCell
        switch (indexPath.row) {
        case 0:
            cell.imageActivity.image = UIImage(named: "distanceIco")
            cell.counterLabel.text = String(format: "%.2f",viewModel.healthData.value.distanceCounter/1000)
            cell.counterUnitsLabel.text = "km"
            break
        case 1:
            cell.imageActivity.image = UIImage(named: "distanceIco")
            cell.counterLabel.text = String(viewModel.healthData.value.energyBurnedCounter)
            cell.counterUnitsLabel.text = "kcal"
            break
        case 2:
            cell.imageActivity.image = UIImage(named: "distanceIco")
            cell.counterLabel.text = String(viewModel.healthData.value.energyBurnedCounter)
            cell.counterUnitsLabel.text = "piętro"
            break
        case 3:
            cell.imageActivity.image = UIImage(named: "distanceIco")
            cell.counterLabel.text = String(viewModel.healthData.value.energyBurnedCounter)
            cell.counterUnitsLabel.text = "minut"
            break
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let collectionWidth = collectionView.frame.width
        let cellWidth = (collectionWidth / 3) - 13.3
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    //MARK: - Progress Bar Setup
    func setupProgressBar(){
        let stepsToDouble =  Double(viewModel.healthData.value.stepsCounter)
        let percent:Double = stepsToDouble / goalSteps
        let percentToInt:Int =  Int(percent * 100)
        goalStepsPercentsLabel.text = String(percentToInt) + "%"
        self.stepperBar.progress = CGFloat(stepsToDouble/goalSteps)
        goalStepsCounterLabel.text = String(viewModel.healthData.value.stepsCounter) + " z " + String(Int(goalSteps)) + " kroków"
    }
    
    // MARK: CoreMotion:
    private func startUpdateStepsLive(){
        viewModel.healthData
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.setupProgressBar()
            }
            .store(in: &subscriptions)
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
