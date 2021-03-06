//
//  DSTaskListViewController.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

class DSTaskListViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    let taskController:DSTaskController = DSTaskController()
    var sectionLabel = UILabel()
    var completedTasks = [DSTask]()
    var uncompletedTasks = [DSTask]()
    var ondemandTasks = [DSTask]()
    var tasksCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -69, 0)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTasksStatus()
        if let tab = self.tabBarController{
            tab.tabBar.items![0].badgeValue = (uncompletedTasks.count == 0 ?  nil : String(uncompletedTasks.count))
        }
    }
    
    func updateTasksStatus(){
        tasksCount = tasks.count
        completedTasks.removeAll()
        uncompletedTasks.removeAll()
        ondemandTasks.removeAll()
        for task in tasks{
            if task.isComplete(){
                if (task.frequencyNumber.intValue == 0){
                    ondemandTasks += [task]
                }else{
                    completedTasks += [task]
                }
            }else{
                uncompletedTasks += [task]
            }
        }
        self.tableView.reloadData()
    }
    
    func configureCellForTask(task: DSTask, cell:UITableViewCell){
        cell.textLabel?.text = task.name
        
        let userDefaults = UserDefaults.standard
        var numberOfTasksCompletedes: Any? = nil
        if let taskDic = userDefaults.object(forKey: task.taskId) as? [String:AnyObject] {
            numberOfTasksCompletedes = (taskDic[PlistFile.Task.FrequencyNumber.rawValue] as! Int == 0) ? nil : taskDic[PlistFile.Task.FrequencyNumber.rawValue] as? String
        }
        
        let tasksCompleted = numberOfTasksCompletedes ?? NSLocalizedString("No tasks", comment: "")
        var detailLabel:String!
        switch(task.frequencyType){
        case Frequency.Daily.Key.rawValue:
            detailLabel = (tasksCompleted as! String) + " " + NSLocalizedString("of", comment: "") + " " + (task.frequencyNumber.description) + " " + NSLocalizedString("for today", comment: "")
        case Frequency.Weekly.Key.rawValue:
            detailLabel = (tasksCompleted as! String) + NSLocalizedString("of", comment: "") + (task.frequencyNumber.stringValue) + NSLocalizedString("for this week", comment: "")
            
        case Frequency.Monthly.Key.rawValue:
            detailLabel = (tasksCompleted as! String) + NSLocalizedString("of", comment: "") + (task.frequencyNumber.stringValue) + NSLocalizedString("for this month", comment: "")
            
        default:
            detailLabel = NSLocalizedString("Fill this in as needed", comment: "")
        }
        
        cell.detailTextLabel?.text = detailLabel
        
        var color:UIColor!
        if (numberOfTasksCompletedes != nil && ((numberOfTasksCompletedes as AnyObject).integerValue)! >= task.frequencyNumber.intValue) && (task.frequencyType != Frequency.OnDemand.rawValue) {
            color = .greenColorDarker()
            cell.imageView?.image = UIImage(named: "OvalChecked")
        } else {
            color = .purple
            if (task.frequencyNumber.intValue == 0){
                cell.imageView?.image = nil
                color = .lightOrangeColor()
            }else{
                cell.imageView?.image = UIImage(named: "OvalNotSelected")
            }
        }
        
        createSideViewForCell(cell, withColor: color)
    }
    
    func moveSubviews(view:UIView, x:CGFloat, y:CGFloat){
        view.subviews.forEach { (element) -> () in
            if element.subviews.count > 0{
                moveSubviews(view: element, x: x, y: y)
            } else {
                element.center = CGPoint(x: element.center.x + x, y: element.center.y + y)
            }
        }
    }
}

// MARK: - TableViewDataSource
extension DSTaskListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasksCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (section == 0) ? sectionLabel : nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if(section == tableView.numberOfSections - ondemandTasks.count){
            return NSLocalizedString("On Demand", comment: "")
        }else if (section == tableView.numberOfSections - ondemandTasks.count - completedTasks.count){
            return NSLocalizedString("Complete", comment: "")
        }else{
            return nil
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd")
            dateFormatter.locale = Locale.current
            
            let now = Date()
            let stringDate = dateFormatter.string(from: now)
            sectionLabel.text = "\(NSLocalizedString("Today", comment: "")), \(now.weekDayString), \(stringDate)\n\(NSLocalizedString("To start an activity tap below", comment: ""))"

            sectionLabel.numberOfLines = 0
            sectionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            sectionLabel.textAlignment = NSTextAlignment.center
            sectionLabel.textColor = UIColor.gray
            //Arrumar a fonte
            sectionLabel.sizeToFit()
            
            return sectionLabel.frame.size.height + 10
            
        case (tableView.numberOfSections - completedTasks.count - ondemandTasks.count):
            return 20
            
        case (tableView.numberOfSections - ondemandTasks.count):
            return 20
            
        default:
            return 0.5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let kTaskCellReuseIdentifier = "TaskCell"
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: kTaskCellReuseIdentifier)
        if indexPath.section < uncompletedTasks.count{
            configureCellForTask(task: uncompletedTasks[indexPath.section], cell: cell)
        }else if(indexPath.section < completedTasks.count + uncompletedTasks.count){
            configureCellForTask(task: completedTasks[indexPath.section - uncompletedTasks.count], cell: cell)
        }else if(indexPath.section < tasksCount){
            configureCellForTask(task: ondemandTasks[indexPath.section - uncompletedTasks.count - completedTasks.count], cell: cell)
        }else{
            //            cell.textLabel?.text = "Sensor Data Query"
            //            cell.detailTextLabel?.text = "This task is used to retrive data from watch"
            //            createSideViewForCell(cell, withColor: .lightOrangeColor())
        }
        return cell
    }
}

// MARK: - TableViewDelegate
extension DSTaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        var task: DSTask? = nil
        if indexPath.section < uncompletedTasks.count{
            task = uncompletedTasks[indexPath.section]
        }else if(indexPath.section < completedTasks.count + uncompletedTasks.count){
            task = completedTasks[indexPath.section - uncompletedTasks.count]
        }else if(indexPath.section < tasksCount){
            task = ondemandTasks[indexPath.section - uncompletedTasks.count - completedTasks.count]
        }else{
            //            let storyboard = UIStoryboard(name: "SensorDataTask", bundle: NSBundle.mainBundle())
            //            let viewController = storyboard.instantiateInitialViewController()
            //            self.presentViewController(viewController!, animated: true, completion: nil)
        }
        if task != nil{
            if let path = Bundle.main.path(forResource: task!.file, ofType: "plist") {
                if let taskDict = NSDictionary(contentsOfFile: path){
                    self.taskController.task = task
                    self.taskController.createTaskWithDictionary(taskDict, andParentViewController: self, willShowTask: true)
                }
            }
        }
    }
}
