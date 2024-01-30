//
//  ChatService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/27/24.
//

import Foundation
import RxSwift
import UIKit
typealias MSGService = MessageService
protocol MessageProtocol{
    var event:PublishSubject<MSGService.Event> {get}
    func fetchChannelDB(channelID:Int)
    func create(chID:Int,chName:String,chat: ChatInfo)
    func create(dm: ChatInfo)
    func getChannelDatas(chID:Int,chName:String)
}
final class MessageService:MessageProtocol{
    
    
    @DefaultsState(\.mainWS) var mainWS
    @DefaultsState(\.userID) var userID
    var event = PublishSubject<MSGService.Event>()
    @BackgroundActor var channelRepostory: ChannelRepository!
    @BackgroundActor var chChatrepository: ChannelChatRepository!
    @BackgroundActor var userRepository: UserInfoRepository!
    @BackgroundActor var imageReferenceCountManager: ImageRCM!
    @BackgroundActor var userReferenceCountManager: UserRCM!
    var taskCounter:TaskCounter = .init()
    init(){
        Task{@BackgroundActor in
            channelRepostory = try await ChannelRepository()
            chChatrepository = try await ChannelChatRepository()
            userRepository = try await UserInfoRepository()
            imageReferenceCountManager = ImageRCM.shared
            userReferenceCountManager = UserRCM.shared
        }
    }
    enum Event{
        case create(response:ChatResponse)
        case check(response:[ChatResponse])
    }
    func create(dm: ChatInfo) {
        
    }
}

