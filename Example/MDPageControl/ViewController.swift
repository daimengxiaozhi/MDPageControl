//
//  ViewController.swift
//  MDPageControl
//
//  Created by 85940969@qq.com on 04/24/2018.
//  Copyright (c) 2018 85940969@qq.com. All rights reserved.
//

import UIKit
import MDPageControl

let mainW = UIScreen.main.bounds.width

class ViewController: UIViewController {

    
    var pageControl = MDPageControl()
    
    var spacePageControl1 = MDPageControl()
    var spacePageControl2 = MDPageControl()
    var spacePageControl3 = MDPageControl()
    var spacePageControl4 = MDPageControl()
    var spacePageControl5 = MDPageControl()
    var spacePageControl6 = MDPageControl()
    var spacePageControl7 = MDPageControl()
    var spacePageControl8 = MDPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        spacePageControl1.frame = CGRect(x: 0, y: 50, width: mainW, height: 50)
        spacePageControl2.frame = CGRect(x: 0, y: 100, width: mainW, height: 50)
        spacePageControl3.frame = CGRect(x: 0, y: 150, width: mainW, height: 50)
        spacePageControl4.frame = CGRect(x: 0, y: 200, width: mainW, height: 50)
        spacePageControl5.frame = CGRect(x: 0, y: 250, width: mainW, height: 50)
        spacePageControl6.frame = CGRect(x: 0, y: 300, width: mainW, height: 50)
        spacePageControl7.frame = CGRect(x: 0, y: 350, width: mainW, height: 50)
        spacePageControl8.frame = CGRect(x: 0, y: 400, width: mainW, height: 50)
        
        self.view.addSubview(spacePageControl1)
        self.view.addSubview(spacePageControl2)
        self.view.addSubview(spacePageControl3)
        self.view.addSubview(spacePageControl4)
        self.view.addSubview(spacePageControl5)
        self.view.addSubview(spacePageControl6)
        self.view.addSubview(spacePageControl7)
        self.view.addSubview(spacePageControl8)
        
        
        spacePageControl1.numberOfPages = 10
        spacePageControl2.numberOfPages = 10
        spacePageControl3.numberOfPages = 10
        spacePageControl4.numberOfPages = 10
        spacePageControl5.numberOfPages = 10
        spacePageControl6.numberOfPages = 10
        spacePageControl7.numberOfPages = 10
        spacePageControl8.numberOfPages = 10
        
        spacePageControl2.indicatorMargin = 20.0
        spacePageControl2.indicatorDiameter = 10.0

        spacePageControl3.alignment = MDPageControlAlignmentLeft;
        spacePageControl4.alignment = MDPageControlAlignmentRight;
    
        
        spacePageControl5.setPageIndicatorImage(currentPageIndicatorImage: #imageLiteral(resourceName: "pikatsho"), pageIndicatorImage: #imageLiteral(resourceName: "pokemen_color"))


        spacePageControl6.setPageIndicatorImage(currentPageIndicatorImage: #imageLiteral(resourceName: "currentPageDot"), pageIndicatorImage: #imageLiteral(resourceName: "pageDot"))


        spacePageControl6.setImage(image: #imageLiteral(resourceName: "searchDot"), pageIndex: 0)
        spacePageControl6.setCurrentImage(image: #imageLiteral(resourceName: "currentSearchDot"),pageIndex: 0)

        spacePageControl6.setName(name: "Search", pageIndex: 0)

        spacePageControl6.setCurrentPage(_currentPage: 1)
//
        
        spacePageControl7.pageIndicatorTintColor = UIColor.darkGray.withAlphaComponent(0.7)
        spacePageControl7.currentPageIndicatorTintColor = UIColor.yellow
        spacePageControl7.setImageMask(image: #imageLiteral(resourceName: "searchMask"), pageIndex: 0)
        
        spacePageControl8.pageIndicatorTintColor = UIColor.red
        spacePageControl8.currentPageIndicatorTintColor = UIColor.red
        spacePageControl8.setPageIndicatorMaskImage(_pageIndicatorMaskImage: UIImage(named: "Pokemon")!)
        
        
        spacePageControl1.addTarget(self, action: #selector(spacePageControl(sender:)), for:  UIControlEvents.valueChanged)
        spacePageControl2.addTarget(self, action: #selector(spacePageControl(sender:)), for:  UIControlEvents.valueChanged)
        spacePageControl3.addTarget(self, action: #selector(spacePageControl(sender:)), for:  UIControlEvents.valueChanged)
        spacePageControl4.addTarget(self, action: #selector(spacePageControl(sender:)), for:  UIControlEvents.valueChanged)
        spacePageControl5.addTarget(self, action: #selector(spacePageControl(sender:)), for:  UIControlEvents.valueChanged)
        spacePageControl6.addTarget(self, action: #selector(spacePageControl(sender:)), for:  UIControlEvents.valueChanged)
        spacePageControl7.addTarget(self, action: #selector(spacePageControl(sender:)), for:  UIControlEvents.valueChanged)
        spacePageControl8.addTarget(self, action: #selector(spacePageControl(sender:)), for:  UIControlEvents.valueChanged)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func spacePageControl(sender:MDPageControl) {
        print("Current Page (MDPageControl : \(sender.currentPage))", terminator: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

