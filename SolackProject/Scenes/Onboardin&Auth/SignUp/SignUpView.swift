//
//  SignUpView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//
import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import Toast
final class SignUpView:BaseVC,View{
    var disposeBag: DisposeBag = .init()
    typealias A = SignUpViewReactor.Action
    func bind(reactor: SignUpViewReactor) {
        let fields:[AuthFieldAble] = [emailField,nicknameField,contactField,pwField,checkPW]
        func actionBinding(_ action : Observable<A>){ action.bind(to: reactor.action).disposed(by: disposeBag) }
        //MARK: -- Action Binding
        actionBinding(emailField.inputText.map{A.setEmail($0)})
        actionBinding(nicknameField.inputText.map{A.setNickname($0)})
        actionBinding(contactField.inputText.map{A.setPhone($0)})
        actionBinding(pwField.inputText.map{A.setSecret($0)})
        actionBinding(checkPW.inputText.map{A.setCheckSecret($0)})
        actionBinding(emailField.validataion.rx.tap.map{A.dobuleCheck})
        // 회원가입 버튼 Action
        fields.forEach{[weak self] (val:AuthFieldAble) in
            actionBinding(val.accAction.map{A.signUpCheck})
        }
        actionBinding(signUpBtn.rx.tap.map{A.signUpCheck})
        
        
        
        //MARK: -- State Binding
        // 텍스트 필드 입력창
        reactor.state.map{$0.email}.distinctUntilChanged().bind(to: emailField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.nickName}.distinctUntilChanged().bind(to: nicknameField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.phone}.bind(to: contactField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.secret}.distinctUntilChanged().bind(to: pwField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.checkSecret}.distinctUntilChanged().bind(to: checkPW.inputText).disposed(by: disposeBag)
        
        
        // 회원가입 유효성 에러 뷰 바인딩
        fieldErrorBinding(reactor)
        // 회원가입 버튼 Interactive
        reactor.state.map{$0.isSignUpAvailable}.distinctUntilChanged().bind(with: self) { owner, isSignUpAvailable in
            owner.isSignUpBtnAvailable(isSignUpAvailable)
        }.disposed(by: disposeBag)
        fields.forEach{ field in
            reactor.state.map{$0.isSignUpAvailable}.bind(to: field.authValid).disposed(by: disposeBag)
        }
        // 이메일 중복 확인 버튼 Interactive
        reactor.state.map{!$0.email.isEmpty}.bind(with: self) { owner, value in
            owner.emailField.isValidate = value
        }.disposed(by: disposeBag)
        // 토스트
        reactor.state.map{$0.signUpToast}.bind(with: self) { owner, type in
            guard let type else {return}
            owner.toastUp(type: type)
        }.disposed(by: disposeBag)
    }
    func fieldErrorBinding(_ reactor: SignUpViewReactor){
        reactor.state.map{$0.emailErrored}.distinctUntilChanged().bind(to:emailField.validFailed).disposed(by: disposeBag)
        reactor.state.map{$0.nickNameErrored}.distinctUntilChanged().bind(to: nicknameField.validFailed).disposed(by: disposeBag)
        reactor.state.map{$0.phoneErrored}.distinctUntilChanged().bind(to: contactField.validFailed).disposed(by: disposeBag)
        reactor.state.map{$0.pwErrored}.distinctUntilChanged().bind(to: pwField.validFailed).disposed(by: disposeBag)
        reactor.state.map{$0.pwErrored}.distinctUntilChanged().bind(to: checkPW.validFailed).disposed(by: disposeBag)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray1
    }
    let scrollView = UIScrollView()
    let signUpBtn = UIButton()
    let emailField = CheckInputFieldView(field: "이메일", placeholder: "이메일을 입력하세요",keyType: .emailAddress,accessoryText: "회원가입")
    let nicknameField = InputFieldView(field: "닉네임", placeholder: "닉네임을 입력하세요",accessoryText: "회원가입")
    let contactField = InputFieldView(field: "연락처", placeholder: "전화번호를 입력하세요",keyType: .phonePad, accessoryText: "회원가입")
    let pwField = InputFieldView(field: "비밀번호", placeholder: "비밀번호를 입력하세요",accessoryText: "회원가입")
    let checkPW = InputFieldView(field: "비밀번호 확인", placeholder: "비밀번호를 한 번 더 입력하세요",accessoryText: "회원가입")
    private var isShowKeyboard:CGFloat? = nil
    lazy var stView = {
        let subViews = [emailField,nicknameField,contactField,pwField,checkPW]
        let st = UIStackView(arrangedSubviews: subViews)
        st.axis = .vertical
        st.spacing = 24
        st.distribution = .fill
        st.alignment = .fill
        return st
    }()
    override func configureView() {
        view.endEditing(true)
        scrollView.endEditing(true)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.dismissMyKeyboard)))
        emailField.tf.autocapitalizationType = .none
        pwField.tf.isSecureTextEntry = true
        checkPW.tf.isSecureTextEntry = true
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    override func configureLayout() {
        view.addSubview(scrollView)
        view.addSubview(signUpBtn)
        scrollView.addSubview(stView)
    }
    override func configureNavigation() {
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "xmark"))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationController?.navigationBar.backgroundColor = .white
        self.isModalInPresentation = true
        self.navigationItem.title = "회원가입"
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true){}
        }.disposed(by: disposeBag)
    }
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).inset(24)
            make.bottom.horizontalEdges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        signUpBtn.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalToSuperview().inset(45)
            make.height.equalTo(44)
        }
    }
}
//MARK: -- 키보드 설정
extension SignUpView{
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func handleKeyboardShow(notification: Notification) {
        
        if let userInfo = notification.userInfo {
            if let keyboardFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) {
                let keyboardFrame = keyboardFrameValue.cgRectValue
                self.isShowKeyboard = keyboardFrame.minY
                let contentInset = UIEdgeInsets(
                    top: 0.0,
                    left: 0.0,
                    bottom: keyboardFrame.size.height,
                    right: 0.0)
                scrollView.contentInset = contentInset
                scrollView.scrollIndicatorInsets = contentInset
            }
        }
    }
    @objc func handleKeyboardHide(notification: Notification){
        self.isShowKeyboard = nil
        let contentInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = contentInset
        scrollView.contentInset = contentInset
    }
}
extension SignUpView{
    func toastUp(type: SignUpToastType){
        var style = ToastStyle()
        style.messageFont = FontType.body.get()
        style.cornerRadius = 8
        style.messageColor = .white
        style.verticalPadding = 9
        style.horizontalPadding = 16
        style.backgroundColor = type.getColor
        let toast = try! navigationController!.view.toastViewForMessage(type.contents, title: nil, image: nil, style: style)
        let radiusHeight = toast.frame.height / 2
        let minY = if let isShowKeyboard{
            isShowKeyboard - 70 - radiusHeight
        }else{
            signUpBtn.frame.minY - 16 - radiusHeight
        }
        navigationController?.view.showToast(toast, duration: ToastManager.shared.duration,point: .init(x: signUpBtn.frame.midX, y: minY),completion: nil)
    }
    func isSignUpBtnAvailable(_ val: Bool){
        signUpBtn.isUserInteractionEnabled = val
        let config = signUpBtn.config.foregroundColor(.white).cornerRadius(8).text("회원가입", font: .title2)
        if val{
            config.backgroundColor(.accent).apply()
        }else{
            config.backgroundColor(.gray3).apply()
        }
    }
}



