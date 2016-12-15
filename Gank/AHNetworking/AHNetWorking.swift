//
//  AHNetWorking.swift
//  Gank
//
//  Created by AHuaner on 2016/12/13.
//  Copyright © 2016年 CoderAhuan. All rights reserved.
//

import UIKit
import Alamofire

typealias Success = (Any) -> Void
typealias Failure = (Error) -> Void

enum MethodType {
    case get
    case post
}

class AHNetWorking {
    class func requestData(_ type: MethodType, URLString: String, parameters: [String : Any]? = nil, success: @escaping Success, failure: @escaping Failure) {
        
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        
        Alamofire.request(URLString, method: method, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    success(result)
                }
                
            case .failure(let error):
                failure(error)
            }
        }
    }
}