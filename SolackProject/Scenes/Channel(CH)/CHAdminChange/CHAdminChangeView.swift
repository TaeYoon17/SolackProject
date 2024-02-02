//
//  CHAdminChangeView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/2/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
final class CHAdminChangeView: BaseVC{
    var disposeBag = DisposeBag()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: ChangeManager.layout)
    var dataSource: DataSource!
    override func configureView() {
        configureCollectionView()
    }
    override func configureLayout() {
        self.view.addSubview(collectionView)
    }
    override func configureNavigation() {
        self.navigationItem.title = "채널 관리자 변경"
        self.navigationItem.leftBarButtonItem = .init(image: .close)
        navigationItem.leftBarButtonItem?.tintColor = .text
        self.isModalInPresentation = true
        navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
