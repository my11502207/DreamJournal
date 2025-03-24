import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var securityService: AppSecurityService
    @AppStorage("userName") private var userName: String = "梦想家"
    @AppStorage("userAvatar") private var userAvatar: String = "person.circle.fill"
    @State private var showingImagePicker = false
    @State private var showingNameEditor = false
    @State private var showingPrivacyTerms = false
    @State private var showingSecuritySettings = false
    @State private var newUserName: String = ""
    @State private var selectedAvatar = 0
    
    // 查询收藏的梦境数量
    @Query(filter: #Predicate<Dream> { $0.isFavorite == true }) private var favoriteDreams: [Dream]
    
    // 版本信息
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // 可选的头像
    private let avatarOptions = [
        "person.circle.fill",
        "moon.stars.fill",
        "cloud.moon.fill",
        "sparkles",
        "star.fill",
        "sun.max.fill",
        "leaf.fill",
        "heart.fill",
        "wand.and.stars"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 用户信息卡片
                        UserProfileCard(
                            userName: userName,
                            userAvatar: userAvatar,
                            onEditPhoto: { showingImagePicker = true },
                            onEditName: {
                                newUserName = userName
                                showingNameEditor = true
                            }
                        )
                        
                        // 功能区
                        ProfileSectionView(title: "梦境功能") {
                            NavigationLink(destination: DreamHistoryView()) {
                                ProfileMenuRow(icon: "calendar", title: "梦境历史", iconColor: .blue)
                            }
                            
                            NavigationLink(destination: DreamAnalysisView()) {
                                ProfileMenuRow(icon: "chart.pie.fill", title: "梦境分析", iconColor: .purple)
                            }
                            
                            // 新增收藏梦境入口
                            NavigationLink(destination: FavoriteDreamsView()) {
                                ProfileMenuRow(
                                    icon: "heart.fill",
                                    title: "收藏梦境",
                                    subtitle: "\(favoriteDreams.count)个",
                                    iconColor: .red
                                )
                            }
                        }
                        
                        // 设置区
                        ProfileSectionView(title: "设置与信息") {
                            // 添加安全设置入口
                            Button(action: {
                                showingSecuritySettings = true
                            }) {
                                ProfileMenuRow(
                                    icon: "lock.shield",
                                    title: "隐私与安全",
                                    subtitle: securityService.isSecurityEnabled ? "已启用" : "未启用",
                                    iconColor: .green
                                )
                            }
                            
                            Button(action: {
                                showingPrivacyTerms = true
                            }) {
                                ProfileMenuRow(icon: "doc.text", title: "隐私条款", iconColor: .blue)
                            }
                            
                            ProfileMenuRow(icon: "info.circle", title: "版本信息", subtitle: "v\(appVersion) (\(buildNumber))", iconColor: .gray)
                        }
                        
                        // 版权信息
                        Text("©2025 梦境日记 保留所有权利")
                            .font(.caption)
                            .foregroundColor(Color("SubtitleColor"))
                            .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingImagePicker) {
                AvatarPickerView(
                    selectedAvatar: $selectedAvatar,
                    avatarOptions: avatarOptions,
                    userAvatar: $userAvatar
                )
            }
            .sheet(isPresented: $showingPrivacyTerms) {
                PrivacyTermsView()
            }
            .sheet(isPresented: $showingSecuritySettings) {
                SecuritySettingsView(securityService: securityService)
            }
            .alert("修改用户名", isPresented: $showingNameEditor) {
                TextField("输入新用户名", text: $newUserName)
                Button("取消", role: .cancel) { }
                Button("保存") {
                    if !newUserName.isEmpty {
                        userName = newUserName
                    }
                }
            } message: {
                Text("请输入你想要使用的新用户名")
            }
        }
    }
}

// 用户信息卡片
struct UserProfileCard: View {
    let userName: String
    let userAvatar: String
    let onEditPhoto: () -> Void
    let onEditName: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 头像
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: userAvatar)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundColor(Color("AccentColor"))
                    .background(
                        Circle()
                            .fill(Color("CardBackgroundColor"))
                            .frame(width: 100, height: 100)
                    )
                    .padding(5)
                
                Button(action: onEditPhoto) {
                    ZStack {
                        Circle()
                            .fill(Color("AccentColor"))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 5, y: 5)
            }
            .padding(.top, 10)
            
            // 用户名和编辑按钮
            HStack {
                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Button(action: onEditName) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(Color("SubtitleColor"))
                }
                .padding(.leading, 4)
            }
            
            Spacer()
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("CardBackgroundColor"))
        )
    }
}

// 个人资料区块视图
struct ProfileSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("SubtitleColor"))
                .padding(.leading, 8)
            
            VStack(spacing: 1) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardBackgroundColor"))
            )
        }
    }
}

// 菜单行
struct ProfileMenuRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color("SubtitleColor"))
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Color("SubtitleColor"))
        }
        .padding(.vertical, 14)
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
}

// 头像选择器
struct AvatarPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAvatar: Int
    let avatarOptions: [String]
    @Binding var userAvatar: String
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("选择头像")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // 当前选中的头像预览
                    Image(systemName: avatarOptions[selectedAvatar])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color("AccentColor"))
                        .padding()
                        .background(
                            Circle()
                                .fill(Color("CardBackgroundColor"))
                                .frame(width: 140, height: 140)
                        )
                    
                    // 头像选项网格
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                        ForEach(0..<avatarOptions.count, id: \.self) { index in
                            Button(action: {
                                selectedAvatar = index
                            }) {
                                Image(systemName: avatarOptions[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .foregroundColor(selectedAvatar == index ? .white : Color("SubtitleColor"))
                                    .background(
                                        Circle()
                                            .fill(selectedAvatar == index ? Color("AccentColor") : Color("CardBackgroundColor"))
                                            .frame(width: 70, height: 70)
                                    )
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        userAvatar = avatarOptions[selectedAvatar]
                        dismiss()
                    }) {
                        Text("确认选择")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("AccentColor"))
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 隐私条款视图
struct PrivacyTermsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("隐私条款")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            Text("最后更新日期: 2025年3月7日")
                                .font(.subheadline)
                                .foregroundColor(Color("SubtitleColor"))
                                .padding(.bottom, 20)
                            
                            PrivacySection(
                                title: "数据收集与使用",
                                content: "梦境日记应用尊重您的隐私，所有梦境数据均存储在您的设备本地，我们不会收集或传输您的梦境内容至服务器。应用仅收集必要的匿名使用数据，用于改进应用体验。"
                            )
                            
                            PrivacySection(
                                title: "权限使用说明",
                                content: "麦克风权限：用于语音转文字功能，方便您快速记录梦境。\n语音识别权限：用于将您的语音转换为文字。\n这些权限都是可选的，您可以在设备设置中随时启用或禁用。"
                            )
                            
                            PrivacySection(
                                title: "数据安全",
                                content: "我们采用业界标准的加密技术保护您的梦境数据。所有数据都存储在设备的安全区域，未经您的明确许可，其他应用无法访问。"
                            )
                            
                            PrivacySection(
                                title: "第三方服务",
                                content: "本应用使用Apple提供的语音识别服务。使用该功能时，您的语音数据将被临时发送至Apple服务器进行处理，但不会被存储或用于其他目的。"
                            )
                            
                            PrivacySection(
                                title: "数据备份",
                                content: "您可以通过iCloud备份应用数据。启用此功能后，您的梦境数据将被加密并存储在您的iCloud账户中。我们无法访问这些备份数据。"
                            )
                            
                            PrivacySection(
                                title: "联系我们",
                                content: "如果您对我们的隐私政策有任何疑问或建议，请发送邮件至：support@dreamjournal.app"
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("隐私条款", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 隐私条款区块
struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(content)
                .font(.body)
                .foregroundColor(Color("SubtitleColor"))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
            
            Divider()
                .background(Color("BorderColor"))
                .padding(.vertical, 8)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
