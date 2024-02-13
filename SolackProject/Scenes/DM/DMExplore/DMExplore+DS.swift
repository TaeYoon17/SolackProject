//
//  DMInviteView+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 2/13/24.
//

import UIKit
import SwiftUI
import RxSwift
extension DMExplore{
    final class DataSource: UICollectionViewDiffableDataSource<String,ChangeManagerListItem>{
        var disposeBag = DisposeBag()
        @DefaultsState(\.userID) var userID
        init(reactor: DMExploreReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, ChangeManagerListItem>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.initSnapshot()
            reactor.state.map{$0.members}.bind { [weak self] responses in
                guard let self else {return}
                Task{
                    var items:[ChangeManagerListItem] = []
                    for response in responses{
                        if response.userID == self.userID { continue }
                        let thumbnailImage = if let imageURL = response.profileImage,let imageData = await NM.shared.getThumbnail(imageURL){
                            Image(uiImage:UIImage.fetchBy(data: imageData, type: .small))
                        }else{
                            Image(uiImage: .noPhotoA)
                        }
                        let item = ChangeManagerListItem(userID: response.userID, nickName: response.nickname, profileImage: thumbnailImage, email: response.email)
                        items.append(item)
                    }
                    await MainActor.run {
                        self.setSnapshot(items:items)
                    }
                }
            }.disposed(by: disposeBag)
        }
        @MainActor func initSnapshot(){
            var snapshot = NSDiffableDataSourceSnapshot<String,ChangeManagerListItem>()
            snapshot.appendSections(["관리자"])
            snapshot.appendItems([])
            apply(snapshot,animatingDifferences: true)
        }
        @MainActor func setSnapshot(items:[ChangeManagerListItem]){
            var snapshot = snapshot()
            snapshot.deleteAllItems()
            snapshot.appendSections(["관리자"])
            snapshot.appendItems(items)
            apply(snapshot,animatingDifferences: true)
        }
    }
}
