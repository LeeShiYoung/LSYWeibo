//
//  StatusBodyTableViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/28.
//  Copyright © 2016年 李世洋. All rights reserved.
// 微博正文

import UIKit

enum showCellMode {
    case original //原创
    case forward //转发
}

class StatusBodyTableViewController: UITableViewController {

    // 微博数据
    var statues: Statuses?
    
    // 评论数据
    var comments: [Comments]?
    
    // 原创/转发
    var mode: showCellMode?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 获取评论数据
        Comments.loadComments(statues!.id) { (comments) in
            self.comments = comments
        }
    }
}

// MARK: - Table view data source
extension StatusBodyTableViewController
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return section == 0 ? 1 : comments?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier.cellID(statues!), forIndexPath: indexPath) as! HomeTableViewCell
            cell.statues = statues
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier.cellID(statues!), forIndexPath: indexPath) as! HomeTableViewCell
            cell.statues = statues
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return tableView.fd_heightForCellWithIdentifier(CellReuseIdentifier.cellID(statues!), cacheByKey: statues!.id, configuration: {[weak self] (cell) in
            (cell as! HomeTableViewCell).statues = self!.statues
        })
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // 重置
        statues?.statusBody = false
    }
}
