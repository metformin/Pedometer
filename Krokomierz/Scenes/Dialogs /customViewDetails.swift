//
//  customViewDetails.swift
//  Krokomierz
//
//  Created by Darek on 04/02/2021.
//

import UIKit

class customViewDetails: UIView {
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    
    private func commonInit(){
        Bundle.main.loadNibNamed("customViewDetails", owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = self.bounds
        //mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainView.getRounded(cornerRadius: 10)
        //setLine()
    }
    
    override var bounds: CGRect {
        didSet {
            setLine()
        }
    }
    
    func setLine(){
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = UIColor.gray.cgColor
        lineLayer.lineWidth = 2
        lineLayer.lineDashPattern = [4,4]
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: frame.width/2, y: 10),
                                CGPoint(x: bounds.width/2, y: bounds.height-10)])
        lineLayer.path = path
        self.layer.addSublayer(lineLayer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

}
