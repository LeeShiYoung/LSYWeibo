//
//  HomeTableViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import MJRefresh
import SnapKit
import ReachabilitySwift
import SVProgressHUD

let HomeIdentifier = "HomeIdentifier"
let HomeNotifitionKey = "HomeNotifitionKey"
let HomePhotoBrowerNotiKey = "HomePhotoBrowerNotiKey"
let UpdateStatuesNotiKey = "UpdateStatuesNotiKey"
let instantiateVC = "instantiateVC"
class HomeTableViewController: BaseTableViewController {
   
    var dataSource: [Statuses]? {
        didSet{
            // 刷新微博数据
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // 未登录
        if !login {
            setUpVisitorView()
            return
        }
        
        // 监听网络连接
        Reachability.eachabilityManger {
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
        }
        
        // 菊花
        SVProgressHUD.showCustom()
        
        setUpNavi()
        // 注册通知
        addNotifiCenter()
        // 提示
        navigationController?.navigationBar.insertSubview(message, atIndex: 0)
        
        // 搜索栏
        tableView.tableHeaderView = searchBar
        
        /*tableView.estimatedRowHeight = 230
        tableView.rowHeight = UITableViewAutomaticDimension*/
        // 加载更多数据
        tableView.mj_header = header
        tableView.mj_footer = footer
        
        loadData()

    }
    
    // 记录当前刷新类别 ( 默认下拉)
    var currentRefresh = true
    
    var since_id: Int = 0
    var max_id: Int = 0
    // 获取微博数据
    private func loadData() {
        
        // 下拉(默认)的参数
        if currentRefresh {
            since_id = dataSource?.first?.id ?? 0
            max_id = 0
        }
        
        // 上拉的参数
        if !currentRefresh {
            max_id = (self.dataSource?.last?.id)! - 1
            since_id = 0
        }
        
        Statuses.loadStatuses(since_id, max: max_id, datas: { (statuses) in
      
            if SVProgressHUD.isVisible() {
                SVProgressHUD.dismiss()
            }
            
            // 下拉刷新的数据
            if self.currentRefresh {
                if self.dataSource != nil {
                    self.message.showNewStatuesCount(statuses.count)
                }
                
                self.dataSource = statuses + (self.dataSource ?? [])
            }
            
            // 上拉加载的数据
            if !self.currentRefresh {
                self.dataSource = self.dataSource! + statuses
            }
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
        }) { (error) in
            
            print(error)
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
        }
    }
   
    private func setUpVisitorView(){
    
        visitorView?.setupVisitorInfo(true, iconStr: "visitordiscover_feed_image_house", text: "关注一些人，回这里看看有什么惊喜")
    }
    
    
    //MARK: - 设置导航栏
    private func setUpNavi() {
        navigationItem.titleView = titleButton
        titleButton.addTarget(self, action: .titleClick, forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("navigationbar_friendattention", targrt: self, action: .letfBarBtnClick)
        navigationItem.rightBarButtonItem = UIBarButtonItem.createBarButtonItem("navigationbar_pop", targrt: self, action: .rightBarBtnClick)
    }

    //MARK: - 弹出下拉菜单
    func titleButtonClick(btn: UIButton) {
        btn.selected = !btn.selected
        
        // modal出的控制器
        let story = UIStoryboard(name: "PopoverViewController", bundle: nil)
        let popVc = story.instantiateInitialViewController()
        
        popVc?.transitionAnimatior(transitior, animationType: .Popover, showMask: false, presented: self, presentingFrame: { () -> CGRect? in
            
            let w: CGFloat = 200.0
            let x = (LSYStruct.screen_w - w) / 2
            return CGRect(x: x, y: 56, width: w, height: 300)
        })
    }
    
    //MARK: - 二维码
    func rightBarButtonClick() {
        let reader = QRViewController()
        reader.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(reader, animated: true)
    }
    
    func leftBarButtonClick() {
        print(#function)
    }
    
    // MARK: - 懒加载
    // 初始化 titleButton
    private lazy var titleButton: TitleButton = {
        let btn = TitleButton()
        btn.setTitle(UserAccount.loadAccount()?.screen_name, forState: UIControlState.Normal)
        return btn
    }()
    
    // 转场动画 驱动
    private lazy var transitior = Transitior()
    
    // 刷新提示信息
    private lazy var message: StatuesMessage = {
       
        let m = "StatuesMessage".loadNib(self) as! StatuesMessage
        m.hidden = true
        return m
    }()
    
    // 初始化 searchBar
    private lazy var searchBar: UISearchBar = {
       
        let search = "SearchBar".loadNib(self) as! UISearchBar
        search.backgroundImage = UIImage(named: "timeline_card_middle_background_highlighted_highlighted")
        return search
    }()
    
    // 下拉刷新 控件
    private lazy var header: MJRefreshHeader = {
       
        let header = MJRefreshNormalHeader(refreshingBlock: {
            
            self.currentRefresh = true
            self.loadData()
        })
        header.setTitle("下拉刷新", forState: MJRefreshState.Idle)
        header.setTitle("释放更新", forState: MJRefreshState.Pulling)
        header.setTitle("加载中...", forState: MJRefreshState.Refreshing)
        header.stateLabel!.font = UIFont.systemFontOfSize(15)
        header.lastUpdatedTimeLabel.hidden = true;
        return header
    }()
    
    // 上拉加载控件
    private lazy var footer: MJRefreshFooter = {
       
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            
            self.currentRefresh = false
            self.loadData()
        })
        
        footer.setTitle("上拉加载更多", forState: MJRefreshState.Idle)
        footer.setTitle("加载中...", forState: MJRefreshState.Refreshing)
        footer.stateLabel.font = UIFont.systemFontOfSize(15)
        return footer
    }()

    
    deinit
    {
        Reachability.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - NSNotificationCenter
extension HomeTableViewController
{
    func changeTitleButtonSelect(noti: NSNotification) {
        titleButton.selected = noti.object as! Bool
    }
    
    // 创建 图片浏览器
    func createPhotoBrower(noti: NSNotification) {

        let browser = noti.userInfo!["browser"] as! LSYPhotoBrowserViewController
        presentViewController(browser, animated: true, completion: {})
    }
    
    // 刷新
    func upDateStatues() {
        
        loadData()
    }
    
    private func addNotifiCenter() {
        //注册通知 改变 titleButton 状态
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .changeTitleButtonClick, name: HomeNotifitionKey, object: nil)
        
        // 注册通知 创建 图片浏览器
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .createPhotoBrower, name: HomePhotoBrowerNotiKey, object: nil)
        
        // 注册通知 发布微博后刷新
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .upDateStatues, name: UpdateStatuesNotiKey, object: nil)

       if let tab = tableView {
            tab.contentOffset = CGPoint(x: 0, y: 44)
        }
    }
}

// MARK: - Table view data source
extension HomeTableViewController
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let statues = dataSource![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier.cellID(statues), forIndexPath: indexPath) as! HomeTableViewCell
      
        cell.delegate = self
        setCellInfo(cell, index: indexPath, status: statues)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        let statues = dataSource![indexPath.row]
        return tableView.fd_heightForCellWithIdentifier(CellReuseIdentifier.cellID(statues), cacheByKey: statues.id, configuration: {[weak self]  (cell) in
            self!.setCellInfo(cell as! HomeTableViewCell, index: indexPath, status: statues)
        })
    }
 
    // 设置cell
    private func setCellInfo(cell: HomeTableViewCell, index: NSIndexPath, status: Statuses)
    {
        cell.statues = status
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let statu = dataSource![indexPath.row]
        let bodyVC = "StatusBodyTableViewController".storyBoard() as! StatusBodyTableViewController
        bodyVC.statues = statu
        statu.statusBody = true
        navigationController?.pushViewController(bodyVC, animated: true)
    }
}

// MARK: - HomeTableViewCellDelegate
extension HomeTableViewController: HomeTableViewCellDelegate
{
    // 转场 ActionSheet菜单
    func downBtnDidSelected(btn: UIButton) {
        "CustomActionSheetController".storyBoard().transitionAnimatior(transitior, animationType: .CustomActionSheet, showMask: true, presented: self) { () -> CGRect? in
            
            let H: CGFloat = 319
            return CGRect(x: 0, y: LSYStruct.screen_h - H, width: LSYStruct.screen_w, height: H)
        }
    }
    
    // 跳转 webView
    func linkTap(link: String) {
        let webVC = WebViewController()
        webVC.loadString = link
        webVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    // 跳转 转发 微博正文
    func forwardBtnClick(cell: HomeTableViewCell) {
        var index:Int = 0
        let indexPath = tableView.indexPathForCell(cell)
        index = indexPath!.row
        let statu = dataSource![index].retweeted_status
        
        let bodyVC = "StatusBodyTableViewController".storyBoard() as! StatusBodyTableViewController
        bodyVC.statues = statu
        statu!.statusBody = true
        navigationController?.pushViewController(bodyVC, animated: true)
    }
}

// MARK: - Selector
private extension Selector {

    static let titleClick = #selector(HomeTableViewController.titleButtonClick(_:))
    static let rightBarBtnClick = #selector(HomeTableViewController.rightBarButtonClick)
    static let letfBarBtnClick = #selector(HomeTableViewController.leftBarButtonClick)
    static let upDateStatues = #selector(HomeTableViewController.upDateStatues)
    static let changeTitleButtonClick = #selector(HomeTableViewController.changeTitleButtonSelect(_:))
    static let createPhotoBrower = #selector(HomeTableViewController.createPhotoBrower(_:))
    
}
