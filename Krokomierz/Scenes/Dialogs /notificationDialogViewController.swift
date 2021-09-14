//
//  customPopUpViewController.swift
//  Krokomierz
//
//  Created by Darek on 15/01/2021.
//


import UIKit
import Combine

class notificationDialogViewController: UIViewController{
    var subscriptions = Set<AnyCancellable>()

    let notificationManager = NotificationManager()
    @IBOutlet weak var notificationSegment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationManager.checkIfNotificationIsEnabled()
            .receive(on: DispatchQueue.main)
            .sink { results in
                if results == true {
                    self.notificationSegment.selectedSegmentIndex = 1
                } else {
                    self.notificationSegment.selectedSegmentIndex = 0
                }
            }.store(in: &subscriptions)
    }
}


