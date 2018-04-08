//
//  SplashViewController.swift
//  DoneList
//
//  Created by Khanh Pham on 7/4/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SplashViewController: UIViewController {

    private var loadingIndicator: UIActivityIndicatorView!
    private var retryButton: UIButton!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBinding()
    }

    private func setupView() {
        view.backgroundColor = .white

        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

        retryButton = UIButton()
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setTitleColor(.blue, for: .normal)

        view.addSubview(loadingIndicator)
        view.addSubview(retryButton)

        loadingIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        retryButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottomConstraint).offset(-20)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(120)
            make.height.greaterThanOrEqualTo(40)
        }

        retryButton.isHidden = true
    }

    private func setupBinding() {
        rx.viewWillAppear
            .take(1)
            .bind { [unowned self] (_) in
                self.loadData()
            }
            .disposed(by: disposeBag)

        retryButton.rx.tap
            .asObservable()
            .bind { [unowned self] in
                self.retryButton.isHidden = true
                self.loadData()
            }
            .disposed(by: disposeBag)
    }

    private func loadData() {
        App.load()
            .subscribe(onCompleted: { [unowned self] in
                self.goNext()
            }, onError: { [unowned self] error in
                self.showError(error)
            })
            .disposed(by: disposeBag)
    }

    private func showError(_ error: Error) {
        retryButton.isHidden = false
        let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    private func goNext() {
        AppDelegate.shared.rootViewController.showMainScreen()
    }

}
