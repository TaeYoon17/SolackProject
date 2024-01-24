//
//  ImageRC.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
struct ImageItem: RCMTableConvertable{
    var name: String
    var count: Int
}
typealias IRCM = ImageRCM
final class ImageRCM: RCMAble{
    typealias Item = ImageItem
    typealias Table = RCMTable
    
    @MainActor var repository = ReferenceRepository<RCMTable>()
    static let shared = ImageRCM()
    var instance: [Item.ID : ImageItem] = [:]
    private init(){
        Task{
            await resetInstance()
        }
    }
    @MainActor private func resetInstance() async {
        let res = repository.getAllTable().reduce(into: [:]) {
            $0[$1.id] = ImageItem(name: $1.name, count: $1.count)
        }
        self.instance = res
    }
    func plusCount(id: Item.ID) async {
        if instance[id] == nil{
            instance[id] = ImageItem(name: id, count: 1)
        }else{
            instance[id]?.count += 1
        }
    }
    func minusCount(id: Item.ID) async {
        instance[id]?.count -= 1
    }
    
    func insertRepository(item: Item) async{
        await repository.insert(item: item)
    }
    func saveRepository() async {
        for (k,v) in instance{
            await self.repository.insert(item: v)
        }
        await repository.clearTable(type: .emptyBT, format: .jpg)
        await resetInstance()
    }
//    func apply(_ snapshot: ImageRCM.SnapShot){
//        instance = snapshot.instance
//    }
//    var snapshot:SnapShot{ SnapShot(irc: self) }
    var snapshot: SnapShot{
        SnapShot(irc: self)
    }
    
    func apply(_ snapshot: SnapShot) {
        instance = snapshot.instance
    }
}


extension ImageRCM{
//    struct SnapShot{
//        typealias Item = ImageItem
//        typealias Table = RCMTable
//        var instance: [Item.ID : ImageItem] = [:]
//        init(irc: ImageRCM){
//            instance = irc.instance
//        }
//        func existItem(id: Item.ID) -> Bool{
//            instance[id] != nil
//        }
//        mutating func plusCount(id: Item.ID) async {
//            if instance[id] == nil{
//                instance[id] = ImageItem(name: id, count: 1)
//            }else{
//                instance[id]?.count += 1
//            }
//        }
//        mutating func minusCount(id: Item.ID)async {
//            instance[id]?.count -= 1
//        }
//    }
    
}
