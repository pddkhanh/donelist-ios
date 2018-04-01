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

class ItemsListViewController: UIViewController, UITableViewDelegate {

    private var tableView: UITableView!
    private let ItemCellIdentifier = "ItemCell"
    private let itemsRepo = DoneItemsRepository()
    private let disposeBag = DisposeBag()
    private var addBtn: UIBarButtonItem!
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, DoneItemModel>>!

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        tableView = UITableView()
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: ItemCellIdentifier)

        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        navigationItem.title = "Dones"
        addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addBtn

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
    }

    private func fakeData() {
        itemsRepo.save(item: DoneItemModel(title: "Item 1"))
        itemsRepo.save(item: DoneItemModel(title: "Item 2"))
        itemsRepo.save(item: DoneItemModel(title: "Item 3"))
    }

    private func addItem() {
        tableView.setEditing(false, animated: true)
        let alert = UIAlertController(title: "What did you get done?", message: "", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [itemsRepo] (action) in
            guard let tf = alert.textFields?.first else { return }
            guard let title = tf.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else { return }
            itemsRepo.save(item: DoneItemModel(title: title))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func removeItem(_ item: DoneItemModel) {
        let alert = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [itemsRepo] (action) in
            itemsRepo.remove(itemId: item.id)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func editItem(_ item: DoneItemModel) {
        let alert = UIAlertController(title: "What did you get done?", message: "", preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.text = item.title
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [itemsRepo] (action) in
            guard let tf = alert.textFields?.first else { return }
            guard let title = tf.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else { return }
            var update = item
            update.title = title
            itemsRepo.save(item: update)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func setupBinding() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        addBtn.rx.tap
            .bind { [unowned self] _ in
                self.addItem()
            }
            .disposed(by: disposeBag)

        dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, DoneItemModel>>(
            configureCell: { [unowned self] _, tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: self.ItemCellIdentifier, for: indexPath)
                    as! ItemTableViewCell
                cell.configure(with: model)
                return cell
            },
            canEditRowAtIndexPath: { _, _ in true }
        )


        itemsRepo.items()
            .asDriver(onErrorJustReturn: [])
            .map { [AnimatableSectionModel(model: "", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .asObservable()
            .bind(onNext: { [unowned self] idx in self.tableView.deselectRow(at: idx, animated: true) })
            .disposed(by: disposeBag)

    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .destructive, title: "Remove") { [weak self] (action, indexPath) in
            guard let weakSelf = self else { return }
            let item = weakSelf.dataSource[indexPath]
            weakSelf.removeItem(item)
        }

        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (action, indexPath) in
            guard let weakSelf = self else { return }
            let item = weakSelf.dataSource[indexPath]
            weakSelf.editItem(item)
        }

        return [removeAction, editAction]
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
