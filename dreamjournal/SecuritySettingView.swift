//
//  SecuritySavingView.swift
//  dreamjournal
//
//  Created by kevin on 2025/3/24.
//

import SwiftUI
import LocalAuthentication

struct SecuritySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var securityService: AppSecurityService
    @State private var isSecurityEnabled: Bool
    @State private var useBiometric: Bool
    @State private var showConfirmDisableAlert = false
    
    init(securityService: AppSecurityService) {
        self._isSecurityEnabled = State(initialValue: securityService.isSecurityEnabled)
        self._useBiometric = State(initialValue: securityService.useBiometric)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 安全设置卡片
                        VStack(alignment: .leading, spacing: 20) {
                            Text("应用锁定")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Toggle(isOn: $isSecurityEnabled) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(Color("AccentColor"))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("启用密码保护")
                                            .foregroundColor(.white)
                                        
                                        Text("离开应用后需要验证才能再次访问")
                                            .font(.caption)
                                            .foregroundColor(Color("SubtitleColor"))
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                            .onChange(of: isSecurityEnabled) { newValue in
                                if newValue {
                                    // 启用安全功能
                                    enableSecurity()
                                } else {
                                    // 确认是否禁用安全功能
                                    showConfirmDisableAlert = true
                                    isSecurityEnabled = true // 先恢复状态，等确认后再改变
                                }
                            }
                            
                            if isSecurityEnabled && securityService.isBiometricAvailable {
                                Divider()
                                    .background(Color("BorderColor"))
                                
                                Toggle(isOn: $useBiometric) {
                                    HStack {
                                        Image(systemName: securityService.biometricType == "Face ID" ? "faceid" : "touchid")
                                            .foregroundColor(Color("AccentColor"))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("使用\(securityService.biometricType)")
                                                .foregroundColor(.white)
                                            
                                            Text("更快捷地解锁应用")
                                                .font(.caption)
                                                .foregroundColor(Color("SubtitleColor"))
                                        }
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                                .onChange(of: useBiometric) { newValue in
                                    securityService.useBiometric = newValue
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackgroundColor"))
                        )
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // 安全说明
                        VStack(alignment: .leading, spacing: 16) {
                            SecurityInfoCard(
                                title: "系统级保护",
                                description: "梦境日记使用您设备的内置安全机制来保护您的数据，无需设置额外的密码。",
                                icon: "shield.checkerboard"
                            )
                            
                            SecurityInfoCard(
                                title: "数据安全",
                                description: "您的梦境日记数据仅存储在本设备上，启用密码保护可以防止他人未经授权访问。",
                                icon: "lock.shield"
                            )
                            
                            if securityService.isBiometricAvailable {
                                SecurityInfoCard(
                                    title: "\(securityService.biometricType)快速解锁",
                                    description: "启用生物识别功能可以更便捷地解锁应用，无需手动输入密码。",
                                    icon: securityService.biometricType == "Face ID" ? "faceid" : "touchid"
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("隐私与安全")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .alert("确认关闭密码保护", isPresented: $showConfirmDisableAlert) {
                Button("取消", role: .cancel) {
                    // 保持开启状态
                }
                
                Button("关闭保护", role: .destructive) {
                    // 确认关闭安全保护
                    securityService.isSecurityEnabled = false
                    isSecurityEnabled = false
                }
            } message: {
                Text("关闭密码保护后，任何人都可以直接访问您的梦境日记。确定要关闭吗？")
            }
        }
    }
    
    // 启用安全功能
    private func enableSecurity() {
        // 首先验证用户身份
        let context = LAContext()
        let reason = "需要验证身份才能启用密码保护"
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    // 验证成功，启用安全功能
                    securityService.isSecurityEnabled = true
                    
                    // 如果设备支持生物识别，默认启用
                    if securityService.isBiometricAvailable {
                        securityService.useBiometric = true
                        useBiometric = true
                    }
                } else {
                    // 验证失败，回滚状态
                    isSecurityEnabled = false
                }
            }
        }
    }
}

// 安全信息卡片组件
struct SecurityInfoCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color("AccentColor"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color("SubtitleColor"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("CardBackgroundColor"))
        )
    }
}

struct SecuritySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SecuritySettingsView(securityService: AppSecurityService())
            .environmentObject(AppSecurityService())
            .preferredColorScheme(.dark)
    }
}
