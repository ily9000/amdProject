//
//  ViewController.swift
//  amslerGrid
//
//  Created by Admin on 10/1/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

protocol PushScreenDelegate{
    func pushNextScreen(completed: Bool)
}

class GridViewController: UIViewController, PushScreenDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let startY = UIApplication.shared.statusBarFrame.height
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let gridViewFrame = CGRect(x: 0, y: startY,
                                  width: screenWidth, height: screenHeight-90-startY)
        let selectionBoxFrame = CGRect(x: 0, y: screenHeight-90,
                                       width: screenWidth, height: 90)
        let gridView = Gridview(frame: gridViewFrame)
        view.addSubview(gridView)
        let selectionBox = SelectionBox(frame: selectionBoxFrame)
        view.addSubview(selectionBox)
        selectionBox.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pushNextScreen(completed: Bool){
        let vc = DoneUIViewController()
        if  !(completed){
            vc.labelTxt = "Uh, oh, please contact your doctor!"
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }


}

extension UIButton {
    func prettify(){
        backgroundColor = UIColor(red: 16.0/255.0, green: 47.0/255.0, blue: 214.0/255.0, alpha: 1.0)
        layer.borderWidth = 3.0;
//        layer.borderColor = UIColor(red: 8.0/255.0, green: 23.5/255.0, blue: 107.0/255.0, alpha: 1.0).cgColor
        layer.borderColor = UIColor(red: 0/255.0, green: 239/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        layer.cornerRadius = 10.0;
    }
}

class SelectionBox: UIView {
    
    var delegate: PushScreenDelegate!
    
    var questions = ["Do any of the lines in the grid appear wavy, blurred, or distorted?",
                     "Do all the boxes in the grid look square and the same size?",
                     "Are there any holes (missing areas) or dark areas in the grid?",
                     "Can you see all corners and sides of the grid (while keeping your eye on the central dot)?"]
    var currQuestIdx = 0
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(questionBox)
        addSubview(yesBtn)
        addSubview(noBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc
    func didPressYes(sender: UIButton){
        questions.remove(at: 0)
        if questions.isEmpty{
            delegate.pushNextScreen(completed: true)
        }
        else{
            questionBox.text = questions[0]
        }
    }
    
    @objc
    func didPressNo(sender: UIButton){
        delegate.pushNextScreen(completed: false)
    }
    
    lazy var questionBox: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 5,
                             width: self.frame.width-10, height: 40)
        label.textColor = UIColor(red: 16.0/255.0, green: 47.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        let question = "Do any of the lines in the grid appear wavy, blurred, or distorted?"
        label.text = question
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        return label
    }()
    
    lazy var yesBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: self.frame.width/2, y: 50,
                              width: self.frame.width/2, height: 40)
        button.setTitle("Yes", for: .normal)
        button.prettify()
        button.addTarget(self, action: #selector(self.didPressYes), for: .touchDown)
        return button
    }()
    
    lazy var noBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 50,
                              width: self.frame.width/2, height: 40)
        button.setTitle("No", for: .normal)
        button.prettify()
        button.addTarget(self, action: #selector(self.didPressNo), for: .touchDown)
        return button
    }()
}

class Gridview: UIView {
    
    var gridCellSize: CGFloat
    var screenWidth: CGFloat
    var maxY: CGFloat!
    
    override init(frame: CGRect) {
        gridCellSize = 23.0
        screenWidth = UIScreen.main.bounds.width
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        maxY = self.frame.maxY
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    func centerRect(verticalLines: Int, horizontalLines: Int) -> CGRect{
        let x = CGFloat(screenWidth/2)
        let radius = CGFloat(3)
        let y = (maxY-self.bounds.minY)/CGFloat(2)
        let point = CGPoint(x: x-6, y: y-radius-13)
        let size = CGSize(width: radius*2, height: radius*2)
        return CGRect(origin: point, size: size)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        
        let screenHeight = self.frame.height
        let numOfHorizLines = Int(screenHeight/gridCellSize)
        let numOfVertLines = Int(screenWidth/gridCellSize)

        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.black.cgColor)
        for vLineNum in 0...numOfVertLines{
            context.move(to: CGPoint(x: 0.0 + CGFloat(vLineNum) * gridCellSize,
                                     y: 0))
            context.addLine(to: CGPoint(x: 0.0 + CGFloat(vLineNum) * gridCellSize,
                                        y: maxY))
            context.strokePath()
        }
        for hLineNum in 0...numOfHorizLines{
            context.move(to: CGPoint(x: 0.0,
                                     y: CGFloat(hLineNum) * gridCellSize))
            context.addLine(to: CGPoint(x: screenWidth,
                                        y: CGFloat(hLineNum) * gridCellSize))
            context.strokePath()
        }
        let centerPntRect = centerRect(verticalLines: numOfVertLines,
                                       horizontalLines: numOfHorizLines)
        context.addEllipse(in: centerPntRect)
        context.drawPath(using: .fillStroke)
    }
}

class DoneUIViewController: UIViewController{
    
    var labelTxt = "Done!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(label)
        label.frame = CGRect(x: 0,
                             y: 0,
                             width: self.view.frame.width,
                             height: self.view.frame.height)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = self.labelTxt
        label.textColor = UIColor.red
        label.textAlignment = .center
        return label
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
