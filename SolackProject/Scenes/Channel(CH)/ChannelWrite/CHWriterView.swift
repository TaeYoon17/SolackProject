//
//  CHWriterView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import Toast
extension CHWriterView{
    enum WriterType{
        case create
        case edit
        var config: WriterConfigureation{
            var config = WriterConfigureation()
            switch self{
            case .create:
                config.buttonText = "생성"
                config.navigationTitle = "채널 생성"
                config.mainField.field = "채널 이름"
                config.mainField.placeholder = "채널 이름을 입력해주세요 (필수)"
                config.mainField.keyType = .default
                config.descriptionField.field = "채널 설명"
                config.descriptionField.placeholder = "채널을 설명하세요 (옵션)"
                config.descriptionField.keyType = .default
                config.descriptionField.autocapitalizationType = .sentences
                config.mainField.autocapitalizationType = .sentences
                config.isAvaileScrollClose = true
            case .edit:break
            }
            
            return config
        }
    }
}
final class CHWriterView:WriterView<CHFailed,CHToastType,WriterReactor<CHFailed, CHToastType>>{
    init(_ provider: ServiceProviderProtocol,type:WriterType){
        switch type{
        case .create:
            super.init(config: type.config, reactor: CHCreateReactor(provider))
        case .edit:
            super.init(config: type.config, reactor: CHCreateReactor(provider))
        }
    }
    init(_ provider: ServiceProviderProtocol){
        var config = WriterConfigureation()
        config.buttonText = "생성"
        config.navigationTitle = "채널 생성"
        config.mainField.field = "채널 이름"
        config.mainField.placeholder = "채널 이름을 입력해주세요 (필수)"
        config.mainField.keyType = .default
        config.descriptionField.field = "채널 설명"
        config.descriptionField.placeholder = "채널을 설명하세요 (옵션)"
        config.descriptionField.keyType = .default
        super.init(config: config,reactor: CHWriterReactor(provider))
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}