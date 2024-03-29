//
//  UserInfoRepository.swift
//  SolackProject
//
//  Created by 김태윤 on 1/28/24.
//

import Foundation
import RealmSwift
typealias UIRepository = UserInfoRepository
@BackgroundActor final class UserInfoRepository: TableRepository<UserInfoTable>{
    let imageRC = ImageRCM.shared
    
    
    func update(table: UserInfoTable,response: UserResponse)async{
        try! await self.realm.asyncWrite({
            table.email = response.email
            table.nickName = response.nickname
            table.profileImage = response.profileImage
        })
    }
    func update(table:UserInfoTable,nickName:String,imagePath:String?) async{
        try! await self.realm.asyncWrite({
            table.nickName = nickName
            table.profileImage = imagePath
        })
    }
    func getTableBy(userID:Int) -> UserInfoTable?{
        return self.getTableBy(tableID: userID)
    }
    func deleteUserIDs(_ ids: [Int]) async {
        for id in ids{
            let table = self.getTableBy(tableID: id)!
            if let profileImage = table.profileImage,FileManager.checkExistDocument(fileName: profileImage){
                FileManager.removeFromDocument(fileName: profileImage)
            }
            await self.delete(item: table)
        }
//        imageRC.apply(snapshot)
//        await imageRC.saveRepository()
    }
}
