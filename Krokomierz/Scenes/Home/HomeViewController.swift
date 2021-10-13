//
//  ViewController.swift
//  Krokomierz
//
//  Created by Darek on 27/12/2020.
//

import UIKit
import Combine
import PopupDialog


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Outlets
    @IBOutlet var mainView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var goalStepsCounterLabel: UILabel!
    @IBOutlet var goalStepsPercentsLabel: UILabel!
    @IBOutlet weak var stepperBar: CircularProgressView!
    
    //MARK: - References
    lazy var viewModel = HomeViewModel()
//    lazy var historyViewModel = HistoryViewModel()
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSummary), name: Notification.Name("NotificationIdentifier"), object: nil)
        
        
        startUpdateStepsLive()
        mainView.setGradientBackground(view: mainView)
        viewModel.setupStartUpdateStepsLive()

//        historyViewModel.getDayRange(forSelectedDate: Date())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //Check the goal steps:
        viewModel.fetchGoalStepsAmount()
        viewModel.goalSteps
            .removeDuplicates()
            .sink { _ in
                self.setupProgressBar()
            }.store(in: &subscriptions)
    }
    //MARK: - Collection View Setup
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
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
            cell.imageActivity.image = UIImage(named: "kcalIco")
            cell.counterLabel.text = String(viewModel.healthData.value.energyBurnedCounter)
            cell.counterUnitsLabel.text = "kcal"
            break
        case 2:
            cell.imageActivity.image = UIImage(named: "tempoIco")
            cell.counterLabel.text = String(viewModel.healthData.value.tempo)
            cell.counterUnitsLabel.text = "tępo"
            break
        case 3:
            cell.imageActivity.image = UIImage(named: "floorsAscendedIco")
            cell.counterLabel.text = String(viewModel.healthData.value.floorsAscended)
            cell.counterUnitsLabel.text = "piętro"
            break
        case 4:
            cell.imageActivity.image = UIImage(named: "floorsDescendedIco")
            cell.counterLabel.text = String(viewModel.healthData.value.floorsDescended)
            cell.counterUnitsLabel.text = "piętro"
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
        let percent:Double = stepsToDouble / viewModel.goalSteps.value
        let percentToInt:Int =  Int(percent * 100)
        goalStepsPercentsLabel.text = String(percentToInt) + "%"
        self.stepperBar.progress = CGFloat(stepsToDouble/viewModel.goalSteps.value)
        goalStepsCounterLabel.text = String(viewModel.healthData.value.stepsCounter) + " z " + String(Int(viewModel.goalSteps.value)) + " kroków"
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
    
    @objc func showSummary(){
        // Create a custom view controller
        let ratingVC = summaryViewController(nibName: "summaryView", bundle: nil)

        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: false)
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK", height: 60) {
        }


        // Add buttons to dialog
        popup.addButtons([buttonOne])

        // Present dialog
        present(popup,animated: true, completion: nil)

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
