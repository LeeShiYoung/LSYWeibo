//
//  StatusBodyTableViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/28.
//  Copyright © 2016年 李世洋. All rights reserved.
// 微博正文

import UIKit

private let commentsIdentifier = "commentsIdentifier"
class StatusBodyTableViewController: UITableViewController {

    // 微博数据
    var statues: Statuses?
    
    // 评论数据
    var comments: [Comments]? {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadComments()
        
        headerView.status = statues
        headerView.buttonsClick = {[weak self](type) in //参数对象
            
            if type.comments {
                self!.loadComments()
            }
            
            if type.forward {
                self!.loadForward()
            }
        }
    }
    
    // 获取评论数据
    private func loadComments() {
        if let id = statues?.id {
            Comments.loadComments(id, finish: { (comments) in
                self.comments = comments
                }, field: { (error) in
                    print(error)
            })
        } else {
            print("发生错误")
        }
    }
    
    // 获取转发数据
    private func loadForward() {
        print("转发")
    }
    
    private lazy var headerView: CommentsHeaderView = "CommentsHeaderView".loadNib(self) as! CommentsHeaderView
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

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier.bodyCellID(statues!), forIndexPath: indexPath) as! HomeTableViewCell
            cell.statues = statues
            return cell
         default:
            let cell = tableView.dequeueReusableCellWithIdentifier(commentsIdentifier, forIndexPath: indexPath) as! CommentsTableViewCell
            cell.comments = comments![indexPath.row]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return tableView.fd_heightForCellWithIdentifier(CellReuseIdentifier.bodyCellID(statues!), cacheByKey: statues!.id, configuration: {[weak self] (cell) in
                (cell as! HomeTableViewCell).statues = self!.statues
                })
        default:
            let comment = comments![indexPath.row]
            return tableView.fd_heightForCellWithIdentifier(commentsIdentifier, cacheByKey: comment.id, configuration: {(cell) in
                (cell as! CommentsTableViewCell).comments = comment
                })
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
        }
        if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            tableView.layoutMargins = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        default:
            return headerView
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 50
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // 重置
        statues?.statusBody = false
    }
}
