//
//  HHMessageFacialView.swift
//  WJMessage
//
//  Created by apple on 16/7/11.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

protocol HHMessageFacialViewDelegate {
    
    func selectedFacialView(str:String?)
    func deleteSelected()
//    func sendFace()
    
}

class HHMessageFacialView: UIView,HHMessageCollectionViewCellDelegate {
    var faces = Array<AnyObject>()
    var delegate: HHMessageFacialViewDelegate?
    let pageControl = UIPageControl()
    var collectionView: UICollectionView?
    var emotionManagers = Array<EaseEmotionManager>()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupSubViews()
    }
    
    func _setupSubViews() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.registerClass(HHMessageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "collectionCell")
        collectionView?.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView")
        
        collectionView?.backgroundColor = UIColor.clearColor()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.alwaysBounceHorizontal = true
        collectionView?.pagingEnabled = true
        collectionView?.userInteractionEnabled = true
        
        addSubview(collectionView!)
//        addSubview(pageControl)
        addConstraint(NSLayoutConstraint(item: collectionView!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: collectionView!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: collectionView!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: collectionView!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))

    }
    
    func loadFacialView(emotionManagers:Array<EaseEmotionManager>,size:CGSize)  {
        self.emotionManagers = emotionManagers;
        collectionView?.reloadData()
    }
    
    func loadFacialView(page:Int)  {
        collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: page), atScrollPosition: .CenteredHorizontally, animated: true)
        let offSet = collectionView!.contentOffset
        if page == 0 {
            collectionView?.setContentOffset(CGPointZero, animated: false)
        } else {
            collectionView?.setContentOffset(CGPointMake(CGRectGetWidth(self.frame)*((offSet.x / CGRectGetWidth(self.frame))+1), 0), animated: false)
        }
    }
    
    func didSendEmotion(emotion:EaseEmotion?) {
        if emotion == nil {
            delegate?.deleteSelected()
        } else {
            delegate?.selectedFacialView(emotion?.emotionId)
        }
    }
}

extension HHMessageFacialView:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if emotionManagers.count == 0 {
            return 1
        }
        return emotionManagers.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section < emotionManagers.count) {
            let emotionManager = emotionManagers[section];
            return emotionManager.emotions.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! HHMessageCollectionViewCell
        cell.sizeToFit()
        let emotionManager = emotionManagers[indexPath.section]
        let emotion = emotionManager.emotions[indexPath.row]
//        cell.backgroundColor = UIColor.blueColor()
        debugPrint(emotion)
        cell.emotion = emotion
        cell.userInteractionEnabled = true
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if emotionManagers.count == 0 {
            return CGSizeZero
        }
        let emotionManager = emotionManagers[section]
        let itemWidth = self.frame.size.width / CGFloat(emotionManager.emotionCol)
        let pageSize = emotionManager.emotionRow*emotionManager.emotionCol
        let lastPage = (pageSize - emotionManager.emotions.count % pageSize);
        if (lastPage < emotionManager.emotionRow || emotionManager.emotions.count % pageSize == 0) {
            return CGSize(width: 0, height: 0)
        } else{
            let size:CGFloat = CGFloat(lastPage) / CGFloat(emotionManager.emotionRow)
            return CGSize(width: size * itemWidth, height: self.frame.size.height);
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionFooter){
            let footerview = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", forIndexPath: indexPath)
            return footerview
        }
        return UICollectionReusableView()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let emotionManager = emotionManagers[indexPath.section]
        let maxRow = emotionManager.emotionRow
        let maxCol = emotionManager.emotionCol
        let itemWidth = self.frame.size.width / CGFloat(maxCol)
        let itemHeight = self.frame.size.height / CGFloat(maxRow)
        debugPrint("\(itemWidth) -- \(itemHeight)")
        return CGSize(width: itemWidth,height:  itemHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    
}

protocol HHMessageCollectionViewCellDelegate {
    func didSendEmotion(emotion:EaseEmotion?)
}


class HHMessageCollectionViewCell: UICollectionViewCell {
    var delegate: HHMessageCollectionViewCellDelegate?
    let imageButton = UIButton(type: .Custom)
    var emotion: AnyObject? {
        didSet {
            if emotion is EaseEmotion {
                let em = emotion as! EaseEmotion
                if em.emotionType == .Gif {
                    imageButton.setImage(UIImage(named: em.emotionThumbnail), forState: .Normal)
                } else if (em.emotionType == .Png) {
                    imageButton.setImage(UIImage(named: em.emotionThumbnail), forState: .Normal)
                    imageButton.imageView?.contentMode = .ScaleAspectFit
                    imageButton.setTitle(nil, forState: .Normal)
                    imageButton.imageEdgeInsets = UIEdgeInsetsZero
                    imageButton.titleEdgeInsets = UIEdgeInsetsZero
                } else {
                    imageButton.titleLabel?.font = UIFont(name: "AppleColorEmoji", size: 29.0)
                    imageButton.setTitle(em.emotionThumbnail, forState: .Normal)
                    imageButton.setImage(nil, forState: .Normal)
                    imageButton.imageEdgeInsets = UIEdgeInsetsZero
                    imageButton.titleEdgeInsets = UIEdgeInsetsZero
                }
            } else {
                imageButton.titleLabel?.font = UIFont.systemFontOfSize(15)
                imageButton.setTitle("删除", forState: .Normal)
                imageButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
                imageButton.imageEdgeInsets = UIEdgeInsetsZero
                imageButton.titleEdgeInsets = UIEdgeInsetsZero
            }
            imageButton.addTarget(self, action: #selector(sendEmotion(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupSubViews()
    }
    
    private func _setupSubViews() {
        imageButton.frame = self.frame
        imageButton.userInteractionEnabled = true
        self.contentView.addSubview(imageButton)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: imageButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        
    }
    
    func sendEmotion(sender:UIButton) {
        if (delegate != nil) {
            if emotion is EaseEmotion {
                delegate?.didSendEmotion(emotion as? EaseEmotion)
            } else {
                delegate?.didSendEmotion(nil)
            }
        }
    }
    
}

