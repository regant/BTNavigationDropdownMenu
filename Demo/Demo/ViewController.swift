//
//  ViewController.swift
//  BTNavigationDropdownMenu
//
//  Created by Pham Ba Tho on 6/8/15.
//  Copyright (c) 2015 PHAM BA THO. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var selectedCellLabel: UILabel!
    var menuView: BTNavigationDropdownMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let items = [
            BTMenuItem(title: "Most Popular"),
            BTMenuItem(title: "Latest"),
            BTMenuItem(title: "Trending"),
            BTMenuItem(title: "Nearest"),
            BTMenuItem(title: "Top Picks")
        ]
        self.selectedCellLabel.text = items.first?.title
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let menuView = BTNavigationDropdownMenu(items: items)
        menuView.cellHeight = 50
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = UIColor(red: 0.0/255.0, green:160.0/255.0, blue:195.0/255.0, alpha: 1.0)
        menuView.cellTextLabelColor = UIColor.whiteColor()
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
        menuView.cellTextLabelAlignment = .Left // .Center // .Right // .Left
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.blackColor()
        menuView.maskBackgroundOpacity = 0.3
        menuView.didSelectItemAtIndexHandler = {
            indexPath, state in
            
            if let indexPath = indexPath {
                print("Did select item at index: \(indexPath)")
                self.selectedCellLabel.text = items[indexPath].title
            } else {
                print("Did deselect item")
                self.selectedCellLabel.text = ""
            }
            
        }
        
        self.navigationItem.titleView = menuView
    }
}

