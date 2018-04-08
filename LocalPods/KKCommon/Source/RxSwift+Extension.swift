//
//  RxSwift+Extension.swift
//
//
//  Created by Khanh Pham on 12/1/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public extension ObservableType {
    public func observeOnMain() -> Observable<Self.E> {
        return observeOn(MainScheduler.instance)
    }

    public func mapVoid() -> Observable<Void> {
        return map { _ in () }
    }

    public func mapAny() -> Observable<Any> {
        return map { $0 }
    }

    public func nullify() -> Observable<Self.E?> {
        return map { $0 }
    }

    public func logError(_ block: @escaping (Swift.Error) -> Void) -> Observable<Self.E> {
        return self.do(onError: block)
    }

    public func skipError() -> Observable<Self.E> {
        return self.catchError { _ in .empty() }
    }

    /// Create Obsearvable that emit true when start and false when got value/error/empty.
    /// E.g.: To indicate a task is in process, like request network.
    public func observeProcessing() -> Observable<Bool> {
        return map { _ in false }
            .catchErrorJustReturn(false)
            .ifEmpty(default: false)
            .startWith(true)
    }

}

public protocol OptionalProtocol {
    associatedtype Wrapped
    var optionalValue: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    public var optionalValue: Wrapped? { return self }
}

public extension ObservableType where Self.E: OptionalProtocol {
    func skipNil() -> Observable<Self.E.Wrapped> {
        return self.filter { $0.optionalValue != nil }.map { $0.optionalValue! }
    }
}

public extension ObserverType {
    func onNextAndCompleted(_ element: E) {
        onNext(element)
        onCompleted()
    }
}

public extension SharedSequence where E: OptionalProtocol {
    func skipNil() -> SharedSequence<SharingStrategy, E.Wrapped> {
        return self.filter { $0.optionalValue != nil }.map { $0.optionalValue! }
    }
}

public extension Reactive where Base: UITextField {
    /// Reactive wrapper for `text` property.
    public var placeholder: Binder<String?> {
        return Binder(self.base) { textField, placeholder in
            textField.placeholder = placeholder
        }
    }

}

public extension Reactive where Base: UIViewController {

    public var viewDidLoad: Observable<Void> {
        return self.sentMessage(#selector(Base.viewDidLoad)).map { _ in () }
    }

    public var viewDidAppear: Observable<Bool> {
        return self.sentMessage(#selector(Base.viewDidAppear(_:))).map { args in
            let animated = (args.first as? Bool) ?? false
            return animated
        }
    }

    public var viewWillAppear: Observable<Bool> {
        return self.sentMessage(#selector(Base.viewWillAppear(_:))).map { args in
            let animated = (args.first as? Bool) ?? false
            return animated
        }
    }
}

public extension Reactive where Base: UITableView {

    /**
     Reactive wrapper for `delegate` message `tableView:didSelectRowAtIndexPath:`.
     
     It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
     or any other data source conforming to `SectionedViewDataSourceType` protocol.
     
     ```
     tableView.rx.modelSelected(MyModel.self)
     .map { ...
     ```
     */
    public func modelSelectedWithIndex<T>(_ modelType: T.Type) -> ControlEvent<(T, IndexPath)> {
        let source: Observable<(T, IndexPath)> = self.itemSelected
            .flatMap { [weak view = self.base as UITableView] indexPath -> Observable<(T, IndexPath)> in
            guard let view = view else {
                return Observable.empty()
            }

            return Observable.just((try view.rx.model(at: indexPath), indexPath))
        }

        return ControlEvent(events: source)
    }
}

public extension Reactive where Base: UICollectionView {

    /// Reactive wrapper for `delegate` message `collectionView(_:didSelectItemAtIndexPath:)`.
    ///
    /// It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
    /// or any other data source conforming to `SectionedViewDataSourceType` protocol.
    ///
    /// ```
    ///     collectionView.rx.modelSelected(MyModel.self)
    ///        .map { ...
    /// ```
    public func modelSelectedWithIndex<T>(_ modelType: T.Type) -> ControlEvent<(T, IndexPath)> {
        let source: Observable<(T, IndexPath)> = itemSelected
            .flatMap { [weak view = self.base as UICollectionView] indexPath -> Observable<(T, IndexPath)> in
            guard let view = view else {
                return Observable.empty()
            }

            return Observable.just((try view.rx.model(at: indexPath), indexPath))
        }

        return ControlEvent(events: source)
    }
}

public extension Reactive where Base: UIViewController {
    public func dismiss(animated: Bool) -> Observable<Void> {
        return Observable.create({[weak controller = base] (observer) -> Disposable in
            guard let vc = controller else {
                observer.onCompleted()
                return Disposables.create()
            }
            vc.dismiss(animated: animated, completion: {
                observer.onNextAndCompleted(())
            })

            return Disposables.create()
        })
    }

    public func present(_ viewControllerToPresent: UIViewController, animated: Bool) -> Observable<Void> {
        return Observable.create({ [weak controller = base] (observer) -> Disposable in
            guard let vc = controller else {
                observer.onCompleted()
                return Disposables.create()
            }
            vc.present(viewControllerToPresent, animated: animated, completion: {
                observer.onNextAndCompleted(())
            })

            return Disposables.create()
        })
    }
}

public extension Reactive where Base: UINavigationController {
    public func pushViewController(_ viewController: UIViewController, animated: Bool) -> Observable<Void> {
        return Observable.create({[weak controller = base] (observer) -> Disposable in
            guard let navController = controller else {
                observer.onCompleted()
                return Disposables.create()
            }

            navController.pushViewController(viewController, animated: animated)
            observer.onNextAndCompleted(())
            return Disposables.create()
        })

    }

    public func popViewController(animated: Bool) -> Observable<UIViewController?> {
        return Observable.create({[weak controller = base] (observer) -> Disposable in
            guard let navController = controller else {
                observer.onCompleted()
                return Disposables.create()
            }

            let vc = navController.popViewController(animated: animated)
            observer.onNextAndCompleted(vc)
            return Disposables.create()
        })

    }

    public func popToViewController(_ viewController: UIViewController,
                                    animated: Bool) -> Observable<[UIViewController]?> {
        return Observable.create({[weak controller = base] (observer) -> Disposable in
            guard let navController = controller else {
                observer.onCompleted()
                return Disposables.create()
            }

            let vc = navController.popToViewController(viewController, animated: animated)
            observer.onNextAndCompleted(vc)
            return Disposables.create()
        })
    }

    public func popToRootViewController(animated: Bool) -> Observable<[UIViewController]?> {
        return Observable.create({[weak controller = base] (observer) -> Disposable in
            guard let navController = controller else {
                observer.onCompleted()
                return Disposables.create()
            }

            let vc = navController.popToRootViewController(animated: animated)
            observer.onNextAndCompleted(vc)
            return Disposables.create()
        })
    }

}

// MARK: - Completable

public extension PrimitiveSequenceType where Self.TraitType == RxSwift.SingleTrait {
    public func asCompletable() -> Completable {
        return Completable.create { completable -> Disposable in
            return self.subscribe(onSuccess: { _ in
                completable(.completed)
            }, onError: { error in
                completable(.error(error))
            })
        }
    }
}
