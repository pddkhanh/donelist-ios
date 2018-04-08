//
//  Utils.swift
//  DoneList
//
//  Created by Khanh Pham on 7/4/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import UIKit
import SnapKit

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var rootViewController: RootViewController {
        return window!.rootViewController as! RootViewController
    }
}

extension UIViewController {
    var bottomConstraint: ConstraintItem {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.snp.bottom
        } else {
            return bottomLayoutGuide.snp.top
        }
    }

    var topConstraint: ConstraintItem {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.snp.top
        } else {
            return topLayoutGuide.snp.bottom
        }
    }
}
