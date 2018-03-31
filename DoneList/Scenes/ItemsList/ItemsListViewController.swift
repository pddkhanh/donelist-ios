//
//  ItemsListViewController.swift
//  DoneList
//
//  Created by Khanh Pham on 31/3/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

class ItemsListViewController: UIViewController {

    private var tableView: UITableView!
    private let ItemCellIdentifier = "ItemCell"
    private let itemsRepo = DoneItemsRepository()
    private let disposeBag = DisposeBag()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        tableView = UITableView()
        tableView.rowHeight = 60
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: ItemCellIdentifier)

        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fakeData()
        setupBinding()
    }

    private func fakeData() {
        itemsRepo.save(item: DoneItemModel(title: "Item 1"))
        itemsRepo.save(item: DoneItemModel(title: "Item 2"))
        itemsRepo.save(item: DoneItemModel(title: "Item 3"))
    }

    private func setupBinding() {
        let ds = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, DoneItemModel>>(
            configureCell: { [unowned self] _, tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: self.ItemCellIdentifier, for: indexPath)
                    as! ItemTableViewCell
                cell.configure(with: model)
                return cell
        })

        itemsRepo.items()
            .asDriver(onErrorJustReturn: [])
            .map { [AnimatableSectionModel(model: "", items: $0)] }
            .drive(tableView.rx.items(dataSource: ds))
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .asObservable()
            .bind(onNext: { [unowned self] idx in self.tableView.deselectRow(at: idx, animated: true) })
            .disposed(by: disposeBag)
    }
}

class ItemTableViewCell: UITableViewCell {

    private var titleLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    func configure(with model: DoneItemModel) {
        titleLabel.text = model.title
    }

    private func setupView() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.textColor = UIColor.darkText

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.centerY.equalToSuperview()
        }
    }
}

extension DoneItemModel: IdentifiableType, Equatable {

    public typealias Identity = String

    public var identity: String {
        return id
    }

    public static func == (lhs: DoneItemModel, rhs: DoneItemModel) -> Bool {
        return lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.created == rhs.created
            && lhs.updated == rhs.updated
    }

}
