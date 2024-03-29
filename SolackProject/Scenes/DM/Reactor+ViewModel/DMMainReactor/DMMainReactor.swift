//
//  DMMainReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import ReactorKit
import RxSwift
enum DMMainPresent:Equatable{
    case room(roomID:Int,user:UserResponse)
    case inviteMemberView
}
final class DMMainReactor: Reactor{
    @DefaultsState(\.mainWS) var mainWS
    var initialState: State = .init()
    weak var provider: ServiceProviderProtocol!
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
    }
    enum Action{
        case initAction
        case setRoom(UserResponse)
        case inviteMemberAction
    }
    enum Mutation{
        case setPresent(DMMainPresent?)
        case setMembsers([UserResponse])
        case appendMembers([UserResponse])
        case setRooms([DMRoomResponse])
        case setUnreads([UnreadDMRes])
        case setWSThumbnail(String)
        case isProfileUpdated(Bool)
    }
    struct State{
        var membsers:[UserResponse] = []
        var rooms:[DMRoomResponse] = []
        var roomUnreads:[UnreadDMRes] = []
        var wsThumbnail:String = ""
        var isProfileUpdated = false
        var dialog:DMMainPresent? = nil
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initAction:
            provider.dmService.checkAll(wsID: mainWS.id)
            return Observable.concat([])
        case .setRoom(let response):
            provider.dmService.getRoomID(user: response)
            return Observable.concat([])
        case .inviteMemberAction:
            return Observable.concat([
                .just(.setPresent(.inviteMemberView)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                .just(.setPresent(nil))
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setMembsers(let members):
            state.membsers = members
        case .appendMembers(let members):
            state.membsers.append(contentsOf: members)
        case .setWSThumbnail(let thumbnail):
            state.wsThumbnail = thumbnail
        case .isProfileUpdated(let updated):
            state.isProfileUpdated = updated
        case .setPresent(let present):
            state.dialog = present
        case .setRooms(let rooms):
            state.rooms = rooms
        case .setUnreads(let unreads):
            state.roomUnreads = unreads
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return Observable.merge([mutation,workspaceMutation,profileMutation,dmMutation])
    }
}
