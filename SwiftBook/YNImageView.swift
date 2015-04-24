//
//  YNImageView.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 05.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

protocol ImageProgressDelegate: NSObjectProtocol {
    func didChangeProgress (progress: Float) -> Void
}

class YNImageView: UIImageView, NSURLSessionTaskDelegate, ImageProgressDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareCircleIndicator(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareCircleIndicator (#frame: CGRect) -> Void {

    }
    
    func didChangeProgress(progress: Float) {
        
    }
}
