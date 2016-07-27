//
//  FirstViewController.swift
//  WJMessage
//
//  Created by apple on 16/7/4.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableArray = HHSessionModel.loadSessions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if tableArray == nil {
            tableArray = Array<HHSessionModel>()
        }
    }
}

extension FirstViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? HHSessionCell
        let session = tableArray![indexPath.row]
        cell?.nameLab.text = session.name
        cell?.detailLab.text = session.lastMessage?.content
        cell?.timeLab.text = session.lastMessage?.time
        cell?.pointBtn.setTitle("\(session.unreadMessagesCount)", forState: UIControlState.Normal)
        if #available(iOS 9.0, *) {
            self.registerForPreviewingWithDelegate(self, sourceView: cell!)
        } else {
            // Fallback on earlier versions
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let session = tableArray![indexPath.row]
        let vc = HHMessageViewController()
        vc.session = session
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FirstViewController:UIViewControllerPreviewingDelegate {
    @available(iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let indexPath = tableView.indexPathForCell(previewingContext.sourceView as! UITableViewCell)!
        let session = tableArray![indexPath.row]
        let vc = HHMessageViewController()
        vc.session = session
        
        return UINavigationController(rootViewController: vc)
//        return vc
    }
    
    @available(iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        let nav = viewControllerToCommit as! UINavigationController
        self.navigationController?.pushViewController(nav.topViewController!, animated: true)
    }
}