//
//  TableRepository.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift

@MainActor class TableRepository<T> where T: Object{
    var realm: Realm!
    private(set) var tasks: Results<T>!
    @MainActor var getTasks:Results<T>{ realm.objects(T.self) }
    init?() {
        realm = try! Realm()
    }
    func checkPath(){
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "경로 없음")
    }
    func checkSchemaVersion(){
        do {
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            print("Schema version: \(version)")
        }catch{
            print(error)
        }
    }
    
    @discardableResult func create(item: T)-> Self?{
        do{
            try realm.write{ realm.add(item) }
            tasks = realm.objects(T.self)
        }catch{
            print("생성 문제")
            return nil
        }
        return self
    }
    func createWithUpdate(item: T){
        do{
            try realm.write{ realm.add(item,update: .modified) }
            tasks = realm.objects(T.self)
        }catch{
            print("생성 문제")
        }
    }
    @discardableResult func delete(item: T)-> Self?{
        do{
            try realm.write{
                realm.delete(item)
                print("삭제 완료")
            }
            tasks = realm.objects(T.self)
        }catch{
            print("삭제 안됨")
            return nil
        }
        return self
    }
    @discardableResult func filter<U:_HasPersistedType>(by: KeyPath<T,U>) -> Self? where U.PersistedType:SortableType{
        tasks = tasks.sorted(by: by)
        return self
    }
    @discardableResult func update<U:_HasPersistedType>(item: T,by: WritableKeyPath<T,U>,data: U) -> Self?{
        var item = item
        do{
            try realm.write{ item[keyPath: by] = data }
        }catch{
            print("값 문제")
            return nil
        }
        return self
    }
    func objectByPrimaryKey<U: ObjectId>(primaryKey: U) -> T? {
        return realm?.object(ofType: T.self, forPrimaryKey: primaryKey)
    }
    func getTableBy<U: ObjectId>(tableID: U) -> T?{
        return realm?.object(ofType: T.self, forPrimaryKey: tableID)
    }
    func deleteTableBy<U: ObjectId>(tableID: U?) throws{
        guard let tableID else { throw RepositoryError.TableNotFound }
        guard let obj = realm?.object(ofType: T.self, forPrimaryKey: tableID) else{
            throw RepositoryError.TableNotFound
        }
        delete(item: obj)
        print("Repository 데이터 삭제 완료")
    }
    
}
