//
//  WSService+HomeFeatures.swift
//  SolackProject
//
//  Created by 김태윤 on 1/22/24.
//

import Foundation
import RxSwift
extension WSService{
    func initHome(){
        Task{
            do{
                let allWS = try await NM.shared.checkAllWS()
                if let id = allWS.first?.workspaceID{
                    let homeWS = try await NM.shared.checkWS(wsID: id)
                    if let members = homeWS.workspaceMembers{
                        await updateUserProfile(responses: members)
                    }
                    mainWS.updateMainWSID(id: id, myManaging: homeWS.ownerID == userID)
                    event.onNext(.homeWS(homeWS))
                }else{
                    event.onNext(.homeWS(nil))
                }
            }catch{
                print("홈 초기 설정 실패!!")
                guard authValidCheck(error: error) else{
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                print("걸리기 실패",error)
            }
        }
    }
    func setHomeWS(wsID: Int?) {
        guard let wsID else{
            event.onNext(.homeWS(nil))
            return
        }
        Task{
            let newHomeWS = try await NM.shared.checkWS(wsID:wsID)
            if let members = newHomeWS.workspaceMembers{
                await updateUserProfile(responses: members)
            }
            mainWS.updateMainWSID(id: newHomeWS.workspaceID, myManaging: newHomeWS.ownerID == userID)
            event.onNext(.homeWS(newHomeWS))
        }
    }
}
