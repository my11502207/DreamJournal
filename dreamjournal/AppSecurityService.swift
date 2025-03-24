//
//  AppSecurityService.swift
//  dreamjournal
//
//  Created by kevin on 2025/3/24.
//

import Foundation
import LocalAuthentication

// 应用安全服务 - 处理密码保护和生物识别
class AppSecurityService: ObservableObject {
    // 发布状态变量 - 应用是否已解锁
    @Published var isAppUnlocked: Bool = false
    
    // 用户默认设置的键
    private let securityEnabledKey = "isSecurityEnabled"
    private let useBiometricKey = "useBiometricAuthentication"
    
    // 生物识别认证上下文
    private let authContext = LAContext()
    
    // 检查是否启用了安全功能
    var isSecurityEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: securityEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: securityEnabledKey)
            // 如果禁用了安全功能，应用应该被视为已解锁
            if !newValue {
                isAppUnlocked = true
            }
        }
    }
    
    // 是否使用生物识别
    var useBiometric: Bool {
        get {
            return UserDefaults.standard.bool(forKey: useBiometricKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: useBiometricKey)
        }
    }
    
    // 检查生物识别是否可用
    var isBiometricAvailable: Bool {
        var error: NSError?
        let canEvaluate = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return canEvaluate
    }
    
    // 获取生物识别类型的描述
    var biometricType: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "生物识别"
        }
    }
    
    init() {
        // 初始时检查安全状态
        if !isSecurityEnabled {
            isAppUnlocked = true
        }
    }
    
    // 对应用进行解锁
    func unlockApp(completion: @escaping (Bool, String?) -> Void) {
        // 如果未启用安全功能，应用直接解锁
        if !isSecurityEnabled {
            isAppUnlocked = true
            completion(true, nil)
            return
        }
        
        if useBiometric && isBiometricAvailable {
            authenticateWithBiometric { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.isAppUnlocked = true
                    }
                    completion(success, error)
                }
            }
        } else {
            authenticateWithPasscode { success in
                DispatchQueue.main.async {
                    if success {
                        self.isAppUnlocked = true
                    }
                    completion(success, nil)
                }
            }
        }
    }
    
    // 使用生物识别进行认证
    private func authenticateWithBiometric(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // 检查设备是否支持生物识别
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "需要验证身份才能访问您的梦境日记"
            
            // 执行生物识别认证
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                if success {
                    // 认证成功
                    completion(true, nil)
                } else {
                    // 生物识别失败，提供错误信息
                    var errorMessage = "认证失败"
                    if let error = authError as? LAError {
                        switch error.code {
                        case .authenticationFailed:
                            errorMessage = "无法验证您的身份"
                        case .userCancel:
                            errorMessage = "用户取消了认证"
                        case .userFallback:
                            // 用户选择了备用选项（密码），切换到密码认证
                            self.authenticateWithPasscode { success in
                                completion(success, nil)
                            }
                            return
                        case .biometryNotAvailable:
                            errorMessage = "生物识别功能不可用"
                        case .biometryNotEnrolled:
                            errorMessage = "设备未设置生物识别"
                        default:
                            errorMessage = "认证错误: \(error.localizedDescription)"
                        }
                    }
                    completion(false, errorMessage)
                }
            }
        } else {
            // 设备不支持生物识别，回退到密码
            authenticateWithPasscode { success in
                completion(success, nil)
            }
        }
    }
    
    // 使用设备密码进行认证
    private func authenticateWithPasscode(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        let reason = "需要验证身份才能访问您的梦境日记"
        
        // 使用设备密码进行认证
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // 锁定应用
    func lockApp() {
        if isSecurityEnabled {
            isAppUnlocked = false
        }
    }
}
