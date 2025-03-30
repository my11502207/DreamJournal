//
//  AppLockScreenView.swift
//  dreamjournal
//
//  Created by kevin on 2025/3/24.
//
import SwiftUI
import LocalAuthentication

struct AppLockScreenView: View {
    @EnvironmentObject var securityService: AppSecurityService
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAuthenticating = false
    
    var body: some View {
        ZStack {
            // 背景
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // 应用logo或图标
                Image(systemName: "moon.stars.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("AccentColor"))
                    .padding(.bottom, 20)
                
                Text("梦境日记")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("隐私保护已启用")
                    .font(.headline)
                    .foregroundColor(Color("SubtitleColor"))
                
                // 解锁按钮
                Button(action: authenticate) {
                    HStack(spacing: 12) {
                        if securityService.useBiometric && securityService.isBiometricAvailable {
                            Image(systemName: securityService.biometricType == "Face ID" ? "faceid" : "touchid")
                                .font(.title2)
                        } else {
                            Image(systemName: "lock.open.fill")
                                .font(.title2)
                        }
                        
                        Text("点击解锁")
                            .font(.headline)
                    }
                    .frame(minWidth: 180)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("AccentColor"))
                    )
                    .foregroundColor(.white)
                }
                .disabled(isAuthenticating)
                .padding(.top, 20)
                
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("AccentColor")))
                        .scaleEffect(1.5)
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal, 40)
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("验证失败"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("重试"))
                )
            }
        }
        .onAppear {
            // 如果设置了自动身份验证，在视图出现时立即尝试认证
//            if securityService.useBiometric && securityService.isBiometricAvailable {
//                authenticate()
//            }
        }
    }
    
    // 触发身份验证
    private func authenticate() {
        isAuthenticating = true
        
        securityService.unlockApp { success, error in
            isAuthenticating = false
            
            if !success {
                errorMessage = error ?? "验证失败，请重试"
                showError = true
            }
        }
    }
}

struct AppLockScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AppLockScreenView()
            .environmentObject(AppSecurityService())
            .preferredColorScheme(.dark)
    }
}
