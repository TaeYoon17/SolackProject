//
//  MyProfileEditImageView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/1/24.
//

import Foundation
import SwiftUI

struct MyProfileEditImageView:View{
    @ObservedObject var vm: ProfileImgVM
    @State var prevImage = false
    @State var pickerPresent: Bool = false
    @State var defaultImage:Image? = nil
    let size: CGSize = .init(width: 200, height: 200)
    var body: some View{
        EditImageView(isPresented:$pickerPresent,cropType: .rectangle(size), content: { state in
            switch state{
            case .empty:
                if let defaultImage{
                    defaultImage.resizable().scaledToFill()
                        .transition(.opacity)
                }else{
                    emptyView.transition(.opacity)
                }
            case .failure(_ ):
                Group{
                    if let defaultImage{
                        defaultImage.resizable().scaledToFill()
                    }else{
                        emptyView
                    }
                }.transition(.opacity).onAppear(){
                    print("여기에 토스트 메시지 던지기")
                }
            case .loading(_): ProgressView()
            case .success(let img):
                Group{
                    if let defaultImage{
                        defaultImage.resizable().scaledToFill()
                            .transition(.opacity)
                    }else{
                        emptyView.transition(.opacity)
                    }
                }.animToggler().onAppear(){
                        do{
                            let imgData = try img.imageData(maxMB: 1)
                            print("이미지 가져오기 성공!!")
                            vm.imageData.onNext(imgData)
                        }catch{
                            print("ProfileImageView 오류")
                            print(error)
                        }
                    }
            }
        })
        .onReceive(vm.defaultImage, perform: { value in
            guard let value else {return}
            let uiimage = UIImage.fetchBy(data: value,size: .init(width: 60, height: 60))
            withAnimation {
                self.defaultImage = Image(uiImage: uiimage)
            }
        })
        .frame(width: 70,height: 70)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8 ))
        .overlay(alignment: .bottomTrailing){ // 작은 카메라 아이콘
            smallCameraIcon
        }
    }
    
    var emptyView: some View{
        RoundedRectangle(cornerRadius: 8).fill(.accent)
            .overlay(alignment:.bottom){
                Image(.workspace).resizable().scaledToFit()
                    .frame(width: 48,height: 60)
            }
    }
}
fileprivate extension MyProfileEditImageView{
    var smallCameraIcon: some View{
        Button{
            self.pickerPresent = true
        }label:{
            Image(systemName: "camera.circle.fill")
                .resizable().scaledToFit()
                .tint(.accent)
                .frame(width: 24,height: 24)
                .background(.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white,lineWidth:2))
        }
        .contentShape(.rect.offset(x:10,y:10))
        .offset(x:10,y:10)
    }
}
