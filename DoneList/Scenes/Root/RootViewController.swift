//
//  RootViewController.swift
//  DoneList
//
//  Created by Khanh Pham on 7/4/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    private var current: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        showChild(viewController: SplashViewController())
    }

    func showMainScreen() {
        let vc = ItemsListViewController()
        let navVC = UINavigationController(rootViewController: vc)
        animateFadeTransition(to: navVC, completion: nil)
    }

    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        guard let current = current else {
            showChild(viewController: new)
            completion?()
            return
        }

        current.willMove(toParentViewController: nil)
        addChildViewController(new)

        transition(from: current, to: new, duration: 0.3,
                   options: [.transitionCrossDissolve, .curveEaseOut],
                   animations: {

        }, completion: { completed in
            current.removeFromParentViewController()
            new.didMove(toParentViewController: self)
            self.current = new
            completion?()
        })
    }

    private func showChild(viewController: UIViewController) {
        addChildViewController(viewController)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)

        if let current = current {
            current.willMove(toParentViewController: nil)
            current.view.removeFromSuperview()
            current.removeFromParentViewController()
        }
        current = viewController
    }

}

