//
//  HomeReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
enum HomePresent:Equatable{
    case create
    case explore
    case chatting(chID:Int,chName:String)
}
final class HomeReactor: Reactor{
    let initialState: State = .init()
    weak var provider: ServiceProviderProtocol!
    @DefaultsState(\.mainWS) var mainWS
    enum Action{
        case setPresent(HomePresent?)
        case setMainWS(wsID:String)
        case initMainWS
    }
    enum Mutation{
        case channelDialog(HomePresent?)
        
        case isMasking(Bool)
        case wsTitle(String)
        case wsLogo(String)
        case setUnreads([UnreadsResponse]?)
        case setChannelList([CHResponse]?)
        case isProfileUpdated(Bool)
    }
    struct State{
        var channelDialog:HomePresent? = nil
        var isMasking: Bool? = nil
        var channelList:[CHResponse]? = nil
        var unreads:[UnreadsResponse]? = nil
        var wsTitle:String = ""
        var wsLogo: String = ""
        var isProfileUpdated:Bool = false
    }
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .setPresent(let present):
            switch present{
                case .chatting(chID: let id, chName: let name):
                let unreads = UnreadsResponse(channelID: id, name: name, count: 0)
                return Observable.concat([
                    .just(.setUnreads([unreads])),
                    Observable.just(.channelDialog(present)).delay(.milliseconds(100), scheduler: MainScheduler.instance),
                    Observable.just(.channelDialog(nil)).delay(.milliseconds(100), scheduler: MainScheduler.instance)
                ])
                default:break
            }
            return Observable.concat([
                Observable.just(.channelDialog(present)).delay(.milliseconds(100), scheduler: MainScheduler.instance),
                Observable.just(.channelDialog(nil)).delay(.milliseconds(100), scheduler: MainScheduler.instance)
            ])
        case .setMainWS(wsID: let wsID):
            provider.wsService.setHomeWS(wsID: Int(wsID)!)
            return Observable.concat([])
        case .initMainWS:
            provider.wsService.initHome()
            return Observable.concat([])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .channelDialog(let present):
            state.channelDialog = present
        case .setChannelList(let list):
            state.channelList = list
        case .isMasking(let isMasking):
            state.isMasking = isMasking
        case .wsLogo(let logo):
            state.wsLogo = logo
        case .wsTitle(let title):
            state.wsTitle = title
        case .setUnreads(let responses):
            state.unreads = responses
        case .isProfileUpdated(let update):
            state.isProfileUpdated = update
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let wsService = wsMutationTransform
        let chService = chMutationTransform
        let profileService = provider.profileService.event.flatMap { event -> Observable<Mutation> in
            switch event{
            case .updatedImage:
                return Observable.concat([
                    .just(Mutation.isProfileUpdated(true)).delay(.milliseconds(100), scheduler: MainScheduler.instance),
                   .just(Mutation.isProfileUpdated(false))
              ])
            default: return Observable.concat([])
            }
        }
        return Observable.merge(mutation,wsService,chService,profileService)
    }
}
