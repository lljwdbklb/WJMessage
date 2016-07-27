//
//  HHMessageMoreView.swift
//  WJMessage
//
//  Created by apple on 16/7/13.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

protocol HHMessageMoreViewDelegate {
    func didSelectMoreItem(index:Int)
}

class HHMessageMoreView: UIView {
    var collectionView: UICollectionView?
    var delegate : HHMessageMoreViewDelegate?
    
    
    var items = Array<HHMoreItem>() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func _setupSubViews() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Vertical
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.registerClass(_HHMessageMoreViewCell.classForCoder(), forCellWithReuseIdentifier: "collectionCell")
        
        collectionView?.backgroundColor = UIColor.clearColor()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.alwaysBounceHorizontal = true
        collectionView?.pagingEnabled = true
        collectionView?.userInteractionEnabled = true
        addSubview(collectionView!)
        
        addConstraint(NSLayoutConstraint(item: collectionView!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: collectionView!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: collectionView!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: collectionView!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
}

protocol _HHMessageMoreViewCellDelegate {
    func didSelectItem(model:HHMoreItem)
}
extension HHMessageMoreView:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,_HHMessageMoreViewCellDelegate {
    class _HHMessageMoreViewCell: UICollectionViewCell {
        var delegate:_HHMessageMoreViewCellDelegate?
        var item:HHMoreItem? {
            didSet {
                btn.setTitle(item!.title, forState: .Normal)
                btn.addTarget(self, action: #selector(selectItem), forControlEvents: .TouchUpInside)
                if let image = item!.icon {
                    btn.setImage(image, forState: .Normal)
                }
            }
        }
        class _HHMessageMoreViewCellBtn: UIButton {
            override init(frame: CGRect) {
                super.init(frame: frame)
                titleLabel?.textAlignment = .Center
                self.imageView?.contentMode = .ScaleAspectFit
                self.titleLabel?.font = UIFont.systemFontOfSize(15)
                setTitleColor(UIColor.blackColor(), forState: .Normal)
            }
            
            required init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
            }
            
            override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
                return CGRect(x: 0, y: contentRect.height * 0.6, width: contentRect.width, height: contentRect.height - contentRect.height * 0.6)
            }
            override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
                return CGRect(x: 0, y: 0, width: contentRect.size.width, height: contentRect.height * 0.6)
            }
        }
        
        var btn:UIButton = _HHMessageMoreViewCellBtn()
        override init(frame: CGRect) {
            super.init(frame: frame)
            btn.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(btn)
            
            addConstraint(NSLayoutConstraint(item: btn, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: btn, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: btn, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: btn, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        func selectItem()  {
            delegate?.didSelectItem(item!)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let model = self.items[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! _HHMessageMoreViewCell
        cell.delegate = self
        cell.item = model
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func didSelectItem(model: HHMoreItem) {
        delegate?.didSelectMoreItem(items.indexOf(model)!)
    }
}

