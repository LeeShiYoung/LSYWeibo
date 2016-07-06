//
//  CustomActionTableViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/23.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

let CustomActionTableCellIdentifier = "Identifier"

class CustomActionSheetController: UITableViewController {

    var titles = ["取消收藏", "帮上头条", "移出分组", "取消关注", "屏蔽", "举报"]
    var cancelTitle = "取消"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bounces = false
        
    }
    
    private lazy var sectionView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        return v
    }()
}

// MARK: - Table view data source
extension CustomActionSheetController
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? titles.count : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
        let titlesClourse = {
            (title : String, cell: UITableViewCell) in
            cell.textLabel!.text = title
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.textLabel?.font = UIFont.systemFontOfSize(18.0)
            cell.textLabel?.textColor = UIColor.darkGrayColor()
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CustomActionTableCellIdentifier)
    
        indexPath.section == 0 ? titlesClourse(titles[indexPath.row], cell!) : titlesClourse(cancelTitle, cell!)
        return cell!
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? nil : sectionView
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     
        return section == 0 ? 0 : 10
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    

}

