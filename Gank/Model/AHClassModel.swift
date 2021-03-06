//
//  AHClassModel.swift
//  Gank
//
//  Created by AHuaner on 2016/12/13.
//  Copyright © 2016年 CoderAhuan. All rights reserved.
//

let _idKey = "_id"
let descKey = "desc"
let publishedAtKey = "publishedAt"
let imagesKey = "images"
let urlKey = "url"
let typeKey = "type"
let userKey = "who"

enum AHImageType {
    case noImage, oneImage, moreImage
}

let bottomViewH: CGFloat = 20
let separatorLineH: CGFloat = 8
let cellMargin: CGFloat = 10
let cellMarginWidth: CGFloat = 20
let cellMaxWidth: CGFloat = kScreen_W - 2 * cellMarginWidth
let collectMargin: CGFloat = 5

import UIKit
import SwiftyJSON

class AHClassModel: GankModel {
    
    var images: [String]?
    var imageContainFrame: CGRect = CGRect.zero
    var imageH: CGFloat = 0
    var imageW: CGFloat = 0
    
    // 默认是没有图片
    var imageType: AHImageType = AHImageType.noImage
    
    var isShouldShowMoreButton: Bool = false
    
    var moreBtnFrame: CGRect = CGRect.zero
    
    var isOpen: Bool = false
    
    var _cellH: CGFloat?
    // cell的整体高度
    var cellH: CGFloat {
        if _cellH == nil {
            
            _cellH = separatorLineH
            
            // 文字的高度
            let maxSize = CGSize(width: cellMaxWidth, height: CGFloat(MAXFLOAT))
            let descTextH = desc?.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 15)], context: nil).size.height
            
            var contentTextH: CGFloat = descTextH!
            
            // 文字大于三行
            if descTextH! > UIFont.systemFont(ofSize: 15).lineHeight * 3 {
                contentTextH = UIFont.systemFont(ofSize: 15).lineHeight * 3
                isShouldShowMoreButton = true
            }
            
            if isOpen {
                contentTextH = descTextH!
            }
            
            _cellH = _cellH! + cellMargin * 2 + contentTextH
            
            if isShouldShowMoreButton {
                let moreBtnX = cellMarginWidth - 5
                let moreBtnY = _cellH! - cellMargin
                let moreBtnW: CGFloat = 40.0
                let moreBtnH: CGFloat = 20.0
                self.moreBtnFrame = CGRect(x: moreBtnX, y: moreBtnY, width: moreBtnW, height: moreBtnH)
                
                _cellH = _cellH! + moreBtnH
            }
            
            // 一张图片的高度
            if self.imageType == AHImageType.oneImage {
                // 早期的图片没有托管, 请求没有结果
                // 所以就算有图片,请求获取的宽度和高度也都为0, 只好把高度定死
                if self.imageW == 0 && self.imageH == 0 {
                    let showImageW: CGFloat = maxSize.width * 0.62
                    let showImageH: CGFloat = showImageW
                    let showImageY = _cellH!
                    let showImageX = cellMarginWidth
                    self.imageContainFrame = CGRect(x: showImageX, y: showImageY, width: showImageH, height: showImageW)
                    
                    _cellH = _cellH! + showImageH + cellMargin
                } else if self.imageW >= self.imageH {
                    let showImageW: CGFloat = maxSize.width * 0.62
                    let showImageH: CGFloat = self.imageH * showImageW / self.imageW
                    let showImageY = _cellH!
                    let showImageX = cellMarginWidth
                    self.imageContainFrame = CGRect(x: showImageX, y: showImageY, width: showImageW, height: showImageH)
                    
                    _cellH = _cellH! + showImageH + cellMargin
                } else {
                    let showImageH: CGFloat = maxSize.width * 0.62
                    let showImageW: CGFloat = self.imageW * showImageH / self.imageH
                    let showImageY = _cellH!
                    let showImageX = cellMarginWidth
                    self.imageContainFrame = CGRect(x: showImageX, y: showImageY, width: showImageW, height: showImageH)
                    
                    _cellH = _cellH! + showImageH + cellMargin
                }
            }
            
            // 有多张图片, colectionView的高度
            if self.imageType == AHImageType.moreImage {
                let count = images!.count
                let col: Int = 3
                var imageW: CGFloat = 0
                var containW: CGFloat = 0
                var containH: CGFloat = 0
                var containX: CGFloat = 0
                var containY: CGFloat = 0
                
                if count == 4 {
                    imageW = (maxSize.width - 2 * collectMargin) / CGFloat(col)
                    containW = imageW * 2 + collectMargin
                    containH = containW
                    containX = cellMarginWidth
                    containY = _cellH!
                    self.imageContainFrame = CGRect(x: containX, y: containY, width: containW, height: containH)
                } else {
                    let row: Int = count / col + ((count % col > 0) ? 1 : 0)
                    imageW = (maxSize.width - 2 * collectMargin) / CGFloat(col)
                    containW = (count >= 3) ? maxSize.width : (imageW * 2 + collectMargin)
                    containH = CGFloat(row) * imageW + CGFloat(row - 1) * collectMargin
                    containX = cellMarginWidth
                    containY = _cellH!
                    self.imageContainFrame = CGRect(x: containX, y: containY, width: containW, height: containH)
                }
                _cellH = _cellH! + containH + cellMargin
            }
            
            // 底部时间的高度
            _cellH = _cellH! + bottomViewH
        }
        return _cellH!
    }
    
    init(dict: JSON) {
        super.init()
        for (index, subJson) : (String, JSON) in dict {
            switch index {
            case _idKey:
                self.id = subJson.string
            case descKey:
                self.desc = subJson.string
            case publishedAtKey:
                self.publishedAt = subJson.string
            case urlKey:
                self.url = subJson.string
            case typeKey:
                self.type = subJson.string
            case userKey:
                self.user = subJson.string
            case imagesKey:
                self.images = (subJson.object as AnyObject) as? [String]
            default: break
            }
        }
        
        if let images = self.images {
            if images.count == 1 {
                self.imageType = AHImageType.oneImage
            } else {
                self.imageType = AHImageType.moreImage
            }
        }
        
        // 时间处理
        let time = self.publishedAt! as NSString
        self.publishedAt = time.substring(to: 10) as String
    }
}
