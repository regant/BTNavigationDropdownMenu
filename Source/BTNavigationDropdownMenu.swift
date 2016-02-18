//
//  BTConfiguration.swift
//  BTNavigationDropdownMenu
//
//  Created by Pham Ba Tho on 6/30/15.
//  Copyright (c) 2015 PHAM BA THO. All rights reserved.
//

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

// MARK: BTMenuItem
public class BTMenuItem {
    
    public var title: String
    public var level: Int
    public var state: AnyObject?
    
    public init(title: String, level: Int? = nil, state: AnyObject? = nil) {
        self.title = title
        self.level = level ?? 0
        self.state = state
    }
}

// MARK: BTNavigationDropdownMenu
public class BTNavigationDropdownMenu: UIView {
    
    // The height of the cell. Default is 50
    public dynamic var cellHeight: CGFloat {
        get {
            return self.configuration.cellHeight
        }
        set {
            self.configuration.cellHeight = newValue
        }
    }
    
    // The color of the cell background. Default is whiteColor()
    public dynamic var cellBackgroundColor: UIColor! {
        get {
            return self.configuration.cellBackgroundColor
        }
        set {
            self.configuration.cellBackgroundColor = newValue
        }
    }
    
    public dynamic var cellSeparatorColor: UIColor! {
        get {
            return self.configuration.cellSeparatorColor
        }
        set {
            self.configuration.cellSeparatorColor = newValue
        }
    }
    
    // The color of the text inside cell. Default is darkGrayColor()
    public dynamic var cellTextLabelColor: UIColor! {
        get {
            return self.configuration.cellTextLabelColor
        }
        set {
            self.configuration.cellTextLabelColor = newValue
        }
    }
    
    // The font of the text inside cell. Default is HelveticaNeue-Bold
    public dynamic var cellTextLabelFont: UIFont! {
        get {
            return self.configuration.cellTextLabelFont
        }
        set {
            self.configuration.cellTextLabelFont = newValue
            if let menuTitle = self.menuTitle {
                menuTitle.font = self.configuration.cellTextLabelFont
            }
        }
    }
    
    // The font size of the text inside root cell. Default is 17
    public dynamic var cellTextLabelRootFontSize: CGFloat {
        get {
            return self.configuration.cellTextLabelRootFontSize
        }
        set {
            self.configuration.cellTextLabelRootFontSize = newValue
        }
    }
    
    // The alignment of the text inside cell. Default is .Left
    public dynamic var cellTextLabelAlignment: NSTextAlignment {
        get {
            return self.configuration.cellTextLabelAlignment
        }
        set {
            self.configuration.cellTextLabelAlignment = newValue
        }
    }
    
    // The color of the cell when the cell is selected. Default is lightGrayColor()
    public dynamic var cellSelectionColor: UIColor! {
        get {
            return self.configuration.cellSelectionColor
        }
        set {
            self.configuration.cellSelectionColor = newValue
        }
    }
    
    // The animation duration of showing/hiding menu. Default is 0.3
    public dynamic var animationDuration: NSTimeInterval {
        get {
            return self.configuration.animationDuration
        }
        set {
            self.configuration.animationDuration = newValue
        }
    }
    
    // The arrow next to navigation title
    public dynamic var arrowImage: UIImage! {
        get {
            return self.configuration.arrowImage
        }
        set {
            self.configuration.arrowImage = newValue
            self.menuArrow.image = self.configuration.arrowImage
        }
    }
    
    // The padding between navigation title and arrow
    public dynamic var arrowPadding: CGFloat {
        get {
            return self.configuration.arrowPadding
        }
        set {
            self.configuration.arrowPadding = newValue
        }
    }
    
    // The color of the mask layer. Default is blackColor()
    public dynamic var maskBackgroundColor: UIColor! {
        get {
            return self.configuration.maskBackgroundColor
        }
        set {
            self.configuration.maskBackgroundColor = newValue
        }
    }
    
    // The opacity of the mask layer. Default is 0.3
    public dynamic var maskBackgroundOpacity: CGFloat {
        get {
            return self.configuration.maskBackgroundOpacity
        }
        set {
            self.configuration.maskBackgroundOpacity = newValue
        }
    }
    
    private var configuration = BTConfiguration()
    
    public private(set) var items: [BTMenuItem]
    public private(set) var isShown: Bool
    public var title: String {
        return menuTitle.text ?? ""
    }
    public var defaultTitle: String?
    
    public var didSelectItemAtIndexHandler: ((indexPath: Int?, state: AnyObject?) -> ())?
    
    private var navigationController: UINavigationController?
    
    private var topSeparator: UIView!
    private var menuButton: UIButton!
    private var menuTitle: UILabel!
    private var menuArrow: UIImageView!
    private var backgroundView: UIView!
    private var tableView: BTTableView!
    private var menuWrapper: UIView!
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(defaultTitle: String? = nil, items: [BTMenuItem] = [], selectedIndex: Int = 0) {
        
        // Init stored properties
        let window = UIApplication.sharedApplication().keyWindow!
        self.items = items
        self.isShown = false
        self.defaultTitle = defaultTitle
        
        let title = items.count > selectedIndex
            ? items[selectedIndex].title
            : self.defaultTitle ?? ""
        let titleSize = (title as NSString).sizeWithAttributes([NSFontAttributeName:self.configuration.cellTextLabelFont])
        
        super.init(frame: CGRectMake(0, 0, titleSize.width + (self.configuration.arrowPadding + self.configuration.arrowImage.size.width) * 2, 0))
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toggleMenu"))
        
        // Set up menu title
        self.menuTitle = UILabel()
        self.menuTitle.text = title
        self.menuTitle.font = self.configuration.cellTextLabelFont
        self.menuTitle.textAlignment = self.configuration.cellTextLabelAlignment
        self.addSubview(self.menuTitle)
        
        self.menuArrow = UIImageView(image: self.configuration.arrowImage)
        self.addSubview(self.menuArrow)
        
        // Set up dropdown menu
        let menuWrapperBounds = window.bounds
        
        self.menuWrapper = UIView(frame: CGRectMake(menuWrapperBounds.origin.x, 0, menuWrapperBounds.width, menuWrapperBounds.height))
        self.menuWrapper.clipsToBounds = true
        self.menuWrapper.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Init background view (under table view)
        self.backgroundView = UIView(frame: menuWrapperBounds)
        self.backgroundView.backgroundColor = self.configuration.maskBackgroundColor
        self.backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: "hideMenu");
        self.backgroundView.addGestureRecognizer(backgroundTapRecognizer)
        
        // Init table view
        self.tableView = BTTableView(frame: CGRectMake(menuWrapperBounds.origin.x, menuWrapperBounds.origin.y + 0.5, menuWrapperBounds.width, menuWrapperBounds.height + 300), configuration: self.configuration, items: self.items, selectedIndex: selectedIndex)
        
        self.tableView.selectRowAtIndexPathHandler = {
            indexPath in
            
            let item = self.items[indexPath]
            if let didSelectItemAtIndexHandler = self.didSelectItemAtIndexHandler {
                didSelectItemAtIndexHandler(indexPath: indexPath, state: item.state)
            }
            self.hideMenu()
            self.setMenuTitle(item.title)
        }
        
        // Add background view & table view to container view
        self.menuWrapper.addSubview(self.backgroundView)
        self.menuWrapper.addSubview(self.tableView)
        
        // Add Line on top
        self.topSeparator = UIView(frame: CGRectMake(0, 0, menuWrapperBounds.size.width, 0.5))
        self.topSeparator.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.menuWrapper.addSubview(self.topSeparator)
        
        // Add Menu View to container view
        window.addSubview(self.menuWrapper)
        
        // By default, hide menu view
        self.menuWrapper.hidden = true
    }
    
    public func setMenuTitle(title: String?) {
        self.menuTitle.text = title
        self.updateFrame()
    }
    
    public func setMenuItems(items: [BTMenuItem], selectedIndex: Int = 0) {
        self.items = items
        self.tableView.items = items
        
        dispatch_async(dispatch_get_main_queue()) {
            if !items.isEmpty {
                let indexPath = NSIndexPath(forRow: min(max(selectedIndex, 0), items.count - 1), inSection: 0)
                self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                self.tableView.delegate!.tableView!(self.tableView, didSelectRowAtIndexPath: indexPath)
            } else {
                if let didSelectItemAtIndexHandler = self.didSelectItemAtIndexHandler {
                    didSelectItemAtIndexHandler(indexPath: nil, state: nil)
                }
                self.hideMenu()
                self.setMenuTitle(self.defaultTitle)
            }
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame", let navigationController = self.navigationController {
            // Set up dropdown menu
            self.menuWrapper.frame.origin.y = navigationController.navigationBar.frame.maxY
            self.tableView.reloadData()
        }
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        var needSize = super.sizeThatFits(size)
        if needSize.width > size.width {
            needSize.width = size.width
        }
        return needSize
    }
    
    public override func layoutSubviews() {
        self.menuTitle.sizeToFit()
        self.menuArrow.sizeToFit()
        
        let titleWidth = self.frame.width - self.menuArrow.frame.width - self.configuration.arrowPadding
        if self.menuTitle.frame.width > titleWidth {
            self.menuTitle.frame.size.width = titleWidth
        }
        self.menuTitle.center = CGPoint(x: self.menuTitle.frame.width / 2, y: self.frame.height / 2)
        
        self.menuArrow.center = CGPoint(x: self.menuTitle.frame.maxX + self.configuration.arrowPadding + self.menuArrow.frame.width / 2, y: self.frame.height / 2)
    }
    
    public override func didMoveToSuperview() {
        if let oldNavigationController = self.navigationController {
            oldNavigationController.removeObserver(self, forKeyPath: "frame")
        }
        
        guard let superview = superview else {
            return
        }
        guard let navigationBar = superview as? UINavigationBar else {
            fatalError("BTNavigationDropdownMenu may only be managed by a UINavigationBar")
        }
        guard let navigationController = navigationBar.parentViewController as? UINavigationController else {
            fatalError("BTNavigationDropdownMenu may only be managed by a UINavigationController")
        }
        
        navigationController.view.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
        self.navigationController = navigationController
        
        let titleTextColor = navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor
        self.menuTitle.textColor = titleTextColor ?? UIColor.blackColor()
    }
    
    func updateFrame() {
        if let navigationController = self.navigationController {
            let titleSize = self.menuTitle.sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max))
            let arrowSize = self.menuArrow.sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max))
            self.frame.size.width = titleSize.width + self.configuration.arrowPadding + arrowSize.width
            
            let height = navigationController.navigationBar.frame.height
            self.frame.size.height = height
            
            navigationController.navigationBar.setNeedsLayout()
        }
    }
    
    func showMenu() {
        guard !self.isShown, let navigationController = self.navigationController else {
            return
        }
        
        self.menuWrapper.frame.origin.y = navigationController.navigationBar.frame.maxY
        
        self.isShown = true
        
        // Table view header
        let headerView = UIView(frame: CGRectMake(0, 0, self.frame.width, 300))
        headerView.backgroundColor = self.configuration.cellBackgroundColor
        self.tableView.tableHeaderView = headerView
        
        self.topSeparator.backgroundColor = self.configuration.cellSeparatorColor
        
        // Rotate arrow
        self.rotateArrow()
        
        // Visible menu view
        self.menuWrapper.hidden = false
        
        // Change background alpha
        self.backgroundView.alpha = 0
        
        // Animation
        self.tableView.frame.origin.y = -CGFloat(self.items.count) * self.configuration.cellHeight - 300
        
        // Reload data to dismiss highlight color of selected cell
        self.tableView.reloadData()
        
        self.menuWrapper.superview?.bringSubviewToFront(self.menuWrapper)
        
        UIView.animateWithDuration(
            self.configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.tableView.frame.origin.y = CGFloat(-300)
                self.backgroundView.alpha = self.configuration.maskBackgroundOpacity
            },
            completion: nil
        )
    }
    
    func hideMenu() {
        guard self.isShown else {
            return
        }
        
        // Rotate arrow
        self.rotateArrow()
        
        self.isShown = false
        
        // Change background alpha
        self.backgroundView.alpha = self.configuration.maskBackgroundOpacity
        
        UIView.animateWithDuration(
            self.configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.tableView.frame.origin.y = CGFloat(-200)
            },
            completion: nil
        )
        
        // Animation
        UIView.animateWithDuration(self.configuration.animationDuration, delay: 0, options: UIViewAnimationOptions.TransitionNone,
            animations: {
                self.tableView.frame.origin.y = -CGFloat(self.items.count) * self.configuration.cellHeight - 300
                self.backgroundView.alpha = 0
            },
            completion: {
                _ in
                self.menuWrapper.hidden = true
            }
        )
    }
    
    func rotateArrow() {
        UIView.animateWithDuration(self.configuration.animationDuration,
            animations: {
                [weak self] in
                
                if let selfie = self {
                    selfie.menuArrow.transform = CGAffineTransformRotate(selfie.menuArrow.transform, 180 * CGFloat(M_PI/180))
                }
            }
        )
    }
    
    func toggleMenu() {
        self.isShown
            ? hideMenu()
            : showMenu()
    }
}

// MARK: BTConfiguration
class BTConfiguration {
    var cellHeight: CGFloat!
    var cellBackgroundColor: UIColor?
    var cellSeparatorColor: UIColor?
    var cellTextLabelColor: UIColor?
    var cellTextLabelRootFontSize: CGFloat!
    var cellTextLabelFont: UIFont!
    var cellTextLabelAlignment: NSTextAlignment!
    var cellSelectionColor: UIColor?
    var arrowImage: UIImage!
    var arrowPadding: CGFloat!
    var animationDuration: NSTimeInterval!
    var maskBackgroundColor: UIColor!
    var maskBackgroundOpacity: CGFloat!
    
    init() {
        self.defaultValue()
    }
    
    func defaultValue() {
        // Path for image
        let bundle = NSBundle(forClass: BTConfiguration.self)
        let url = bundle.URLForResource("BTNavigationDropdownMenu", withExtension: "bundle")
        let imageBundle = NSBundle(URL: url!)
        let arrowImagePath = imageBundle?.pathForResource("arrow_down_icon", ofType: "png")
        
        // Default values
        self.cellHeight = 50
        self.cellBackgroundColor = UIColor.whiteColor()
        self.cellSeparatorColor = UIColor.darkGrayColor()
        self.cellTextLabelColor = UIColor.darkGrayColor()
        self.cellTextLabelRootFontSize = 17
        self.cellTextLabelFont = UIFont(name: "HelveticaNeue-Bold", size: self.cellTextLabelRootFontSize)
        self.cellTextLabelAlignment = NSTextAlignment.Left
        self.cellSelectionColor = UIColor.lightGrayColor()
        self.animationDuration = 0.5
        self.arrowImage = UIImage(contentsOfFile: arrowImagePath!)
        self.arrowPadding = 5
        self.maskBackgroundColor = UIColor.blackColor()
        self.maskBackgroundOpacity = 0.3
    }
}

// MARK: Table View
class BTTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    static let cellPaddingOffset: CGFloat = 15
    
    // Public properties
    var configuration: BTConfiguration
    var selectRowAtIndexPathHandler: ((indexPath: Int) -> ())?
    
    // Private properties
    private var items: [BTMenuItem]
    private var selectedIndexPath: Int
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, configuration: BTConfiguration, items: [BTMenuItem], selectedIndex: Int? = nil) {
        self.items = items
        self.selectedIndexPath = selectedIndex ?? 0
        self.configuration = configuration
        
        super.init(frame: frame, style: UITableViewStyle.Plain)
        
        // Setup table view
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.clearColor()
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, withEvent: event) where hitView.findParent(ofType: BTTableViewCell.self) != nil {
            return hitView
        }
        return nil
    }
    
    // Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.configuration.cellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        self.separatorColor = self.configuration.cellSeparatorColor
        let item = self.items[indexPath.row]
        let cell = BTTableViewCell(configuration: self.configuration)
        cell.textLabel.text = item.title
        cell.checked = indexPath.row == selectedIndexPath
        cell.padding = BTTableView.cellPaddingOffset * CGFloat(item.level)
        cell.textLabel.font = cell.textLabel.font.fontWithSize(self.configuration.cellTextLabelRootFontSize - CGFloat(item.level))
        return cell
    }
    
    // Table view delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedIndexPath, inSection: 0)) as? BTTableViewCell {
            cell.checked = false
            cell.backgroundColor = self.configuration.cellBackgroundColor
        }
        
        selectedIndexPath = indexPath.row
        if let selectRowAtIndexPathHandler = self.selectRowAtIndexPathHandler {
            selectRowAtIndexPathHandler(indexPath: indexPath.row)
        }
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BTTableViewCell {
            cell.checked = true
            cell.backgroundColor = self.configuration.cellSelectionColor
        }
    }
    
}

// MARK: Table view cell
class BTTableViewCell: UITableViewCell {
    
    static let separatorHeight: CGFloat = 0.5
    
    override var textLabel: UILabel! {
        get {
            return super.textLabel!
        }
    }
    
    var configuration: BTConfiguration!
    
    var checked: Bool {
        didSet {
            self.accessoryType = checked == true
                ? .Checkmark
                : .None
        }
    }
    
    var padding: CGFloat = 0
    
    init(configuration: BTConfiguration) {
        self.checked = false
        
        super.init(style: .Default, reuseIdentifier: "Cell")
        
        self.configuration = configuration
        
        self.backgroundColor = self.configuration.cellBackgroundColor
        self.tintColor = self.configuration.cellTextLabelColor
        self.selectionStyle = .None
        
        // Init text label
        self.textLabel.textColor = self.configuration.cellTextLabelColor
        self.textLabel.font = self.configuration.cellTextLabelFont
        self.textLabel.textAlignment = self.configuration.cellTextLabelAlignment
        
        // Init separator
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = textLabel.frame
        textLabel.frame = CGRect(x: frame.minX + padding, y: frame.minY, width: frame.width - padding, height: frame.height)
    }
    
}

extension UIView {
    
    var parentViewController: UIViewController? {
        var currentResponder: UIResponder = self
        while let parentResponder = currentResponder.nextResponder() {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            currentResponder = parentResponder
        }
        return nil
    }
    
    func findParent<ViewType: UIView>(ofType type: ViewType.Type) -> ViewType? {
        if let view = self as? ViewType {
            return view
        }
        if let parent = self.superview?.findParent(ofType: type) {
            return parent
        }
        return nil
    }
    
}

extension UIViewController {
    
    // Get ViewController in top present level
    var topPresentedViewController: UIViewController? {
        var target: UIViewController? = self
        while (target?.presentedViewController != nil) {
            target = target?.presentedViewController
        }
        return target
    }
    
    // Get top VisibleViewController from ViewController stack in same present level.
    // It should be visibleViewController if self is a UINavigationController instance
    // It should be selectedViewController if self is a UITabBarController instance
    var topVisibleViewController: UIViewController? {
        if let navigation = self as? UINavigationController {
            if let visibleViewController = navigation.visibleViewController {
                return visibleViewController.topVisibleViewController
            }
        }
        if let tab = self as? UITabBarController {
            if let selectedViewController = tab.selectedViewController {
                return selectedViewController.topVisibleViewController
            }
        }
        return self
    }
    
    // Combine both topPresentedViewController and topVisibleViewController methods, to get top visible viewcontroller in top present level
    var topMostViewController: UIViewController? {
        return self.topPresentedViewController?.topVisibleViewController
    }
    
}
