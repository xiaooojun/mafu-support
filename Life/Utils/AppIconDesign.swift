import SwiftUI

// Logo类型枚举
enum LogoType: String, CaseIterable {
    case dots = "dots"
    case calendar = "calendar"
    case chart = "chart"
    
    var displayName: String {
        switch self {
        case .dots: return "圆点风格"
        case .calendar: return "日历风格"
        case .chart: return "图表风格"
        }
    }
}

// 应用图标设计 - 现代渐变风格
struct AppIconDesign: View {
    var body: some View {
        ZStack {
            // 现代渐变背景
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.3, blue: 0.9), // 紫色
                    Color(red: 0.3, green: 0.7, blue: 0.9), // 蓝色
                    Color(red: 0.2, green: 0.8, blue: 0.6)  // 青色
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 1024, height: 1024)
            
            // 主设计元素
            ZStack {
                // 中心圆形背景 - 带渐变和阴影
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.95), .white.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 650, height: 650)
                    .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                
                // 生活记录图标 - 现代笔记本设计
                VStack(spacing: 25) {
                    // 笔记本封面 - 更大尺寸
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 280, height: 380)
                        .overlay(
                            // 笔记本线条 - 更粗更明显
                            VStack(spacing: 12) {
                                ForEach(0..<15, id: \.self) { _ in
                                    Rectangle()
                                        .fill(.white.opacity(0.4))
                                        .frame(height: 3)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 40)
                        )
                    
                    // 装饰性圆点 - 更大更明显
                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 18, height: 18)
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 18, height: 18)
                        Circle()
                            .fill(Color.green)
                            .frame(width: 18, height: 18)
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 18, height: 18)
                    }
                }
                
                // 右上角装饰 - 代表成长趋势
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ForEach(0..<4, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: CGFloat(8 + index * 4), height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .padding(.trailing, 40)
                    }
                    Spacer()
                }
                .frame(width: 650, height: 650)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

// 深色模式版本的应用图标设计 - 现代渐变风格
struct AppIconDesignDark: View {
    var body: some View {
        ZStack {
            // 深色渐变背景
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.1, blue: 0.4), // 深紫色
                    Color(red: 0.1, green: 0.3, blue: 0.5), // 深蓝色
                    Color(red: 0.1, green: 0.4, blue: 0.3)  // 深青色
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 1024, height: 1024)
            
            // 主设计元素
            ZStack {
                // 中心圆形背景 - 带渐变和阴影
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.98), .white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 650, height: 650)
                    .shadow(color: .black.opacity(0.4), radius: 40, x: 0, y: 20)
                
                // 生活记录图标 - 现代笔记本设计
                VStack(spacing: 25) {
                    // 笔记本封面 - 更大尺寸
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 280, height: 380)
                        .overlay(
                            // 笔记本线条 - 更粗更明显
                            VStack(spacing: 12) {
                                ForEach(0..<15, id: \.self) { _ in
                                    Rectangle()
                                        .fill(.white.opacity(0.5))
                                        .frame(height: 3)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 40)
                        )
                    
                    // 装饰性圆点 - 更大更明显
                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 18, height: 18)
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 18, height: 18)
                        Circle()
                            .fill(Color.green)
                            .frame(width: 18, height: 18)
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 18, height: 18)
                    }
                }
                
                // 右上角装饰 - 代表成长趋势
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ForEach(0..<4, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: CGFloat(8 + index * 4), height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .padding(.trailing, 40)
                    }
                    Spacer()
                }
                .frame(width: 650, height: 650)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

// 图标设计说明
struct IconDesignNotes: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("应用图标设计说明 - 符合苹果官方规范")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("🍎 苹果官方规范:")
                Text("• 不添加自定义圆角 - 苹果系统会自动处理")
                Text("• 使用纯色背景填充整个1024x1024区域")
                Text("• 让系统自动处理圆角和动画效果")
                
                Text("\n🎨 设计理念:")
                Text("• 现代紫色背景体现科技感和专业性")
                Text("• 笔记本图标直观表达记录和整理的概念")
                Text("• 四个彩色圆点代表四个生活模块：情绪、睡眠、健康、爱好")
                Text("• 铅笔图标强调记录和书写的功能")
                Text("• 装饰性圆点营造数据流动的视觉感受")
                
                Text("\n📱 技术规格:")
                Text("• 尺寸：1024x1024 像素")
                Text("• 格式：PNG")
                Text("• 背景：纯色填充，无渐变")
                Text("• 圆角：由苹果系统自动处理")
                Text("• 支持浅色和深色模式")
                
                Text("\n🔧 使用方法:")
                Text("1. 在Xcode中打开AppIcon.appiconset")
                Text("2. 将生成的PNG文件拖拽到对应位置")
                Text("3. 确保所有尺寸都已填充")
                Text("4. 测试在不同设备上的显示效果")
                
                Text("\n✨ 设计优势:")
                Text("• 完全符合苹果官方设计规范")
                Text("• 解决系统动画时的白色边角问题")
                Text("• 清晰的功能表达（记录生活）")
                Text("• 良好的可识别性和记忆性")
                Text("• 让系统自动处理所有视觉效果")
            }
            .font(.body)
            
            Spacer()
        }
        .padding()
    }
}

#Preview("图标设计 - 浅色模式") {
    AppIconDesign()
}




// 应用图标设计 - 现代日历风格
struct AppIconDesignCalendar: View {
    var body: some View {
        ZStack {
            // 现代渐变背景
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.6, blue: 0.9), // 蓝色
                    Color(red: 0.1, green: 0.8, blue: 0.7), // 青色
                    Color(red: 0.3, green: 0.7, blue: 0.5)  // 绿色
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 1024, height: 1024)
            
            // 主设计元素
            ZStack {
                // 中心圆形背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.95), .white.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 650, height: 650)
                    .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                
                // 现代日历设计
                VStack(spacing: 20) {
                    // 日历网格 - 更大更清晰
                    VStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(0..<7, id: \.self) { col in
                                    Circle()
                                        .fill(
                                            row < 1 ? Color.gray.opacity(0.4) :
                                            col == 3 ? Color.blue.opacity(0.8) :
                                            Color.blue.opacity(0.3)
                                        )
                                        .frame(width: 28, height: 28)
                                }
                            }
                        }
                    }
                    
                    // 装饰性元素 - 更大更明显
                    HStack(spacing: 16) {
                        Circle().fill(Color.pink).frame(width: 14, height: 14)
                        Circle().fill(Color.orange).frame(width: 14, height: 14)
                        Circle().fill(Color.green).frame(width: 14, height: 14)
                    }
                }
                
                // 左下角装饰 - 代表时间流逝
                VStack {
                    Spacer()
                    HStack {
                        VStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 3, height: CGFloat(8 + index * 6))
                                    .cornerRadius(1.5)
                            }
                        }
                        .padding(.leading, 40)
                        Spacer()
                    }
                }
                .frame(width: 650, height: 650)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

// 应用图标设计 - 现代图表风格
struct AppIconDesignChart: View {
    var body: some View {
        ZStack {
            // 现代渐变背景
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.5, blue: 0.4), // 深绿色
                    Color(red: 0.2, green: 0.7, blue: 0.5), // 绿色
                    Color(red: 0.3, green: 0.6, blue: 0.7)  // 蓝绿色
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 1024, height: 1024)
            
            // 主设计元素
            ZStack {
                // 中心圆形背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.95), .white.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 650, height: 650)
                    .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                
                // 现代图表设计
                VStack(spacing: 25) {
                    // 图表标题 - 更大
                    Text("📊")
                        .font(.system(size: 60))
                    
                    // 现代柱状图 - 更大更清晰
                    HStack(alignment: .bottom, spacing: 18) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 35, height: 120)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 35, height: 180)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 35, height: 150)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.8), Color.orange.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 35, height: 90)
                            .cornerRadius(6)
                    }
                    
                    // 装饰性元素 - 更大更明显
                    HStack(spacing: 12) {
                        Circle().fill(Color.purple).frame(width: 10, height: 10)
                        Circle().fill(Color.blue).frame(width: 10, height: 10)
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Circle().fill(Color.orange).frame(width: 10, height: 10)
                    }
                }
                
                // 右上角装饰 - 代表数据增长
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: CGFloat(4 + index * 2), height: 3)
                                    .cornerRadius(1.5)
                            }
                        }
                        .padding(.trailing, 40)
                    }
                    Spacer()
                }
                .frame(width: 650, height: 650)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}


// 深色模式版本 - 现代日历风格
struct AppIconDesignCalendarDark: View {
    var body: some View {
        ZStack {
            // 深色渐变背景
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.5), // 深蓝色
                    Color(red: 0.05, green: 0.4, blue: 0.4), // 深青色
                    Color(red: 0.1, green: 0.35, blue: 0.3)  // 深绿色
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 1024, height: 1024)
            
            // 主设计元素
            ZStack {
                // 中心圆形背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.98), .white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 650, height: 650)
                    .shadow(color: .black.opacity(0.4), radius: 40, x: 0, y: 20)
                
                // 现代日历设计
                VStack(spacing: 20) {
                    // 日历网格 - 更大更清晰
                    VStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(0..<7, id: \.self) { col in
                                    Circle()
                                        .fill(
                                            row < 1 ? Color.gray.opacity(0.5) :
                                            col == 3 ? Color.blue.opacity(0.9) :
                                            Color.blue.opacity(0.4)
                                        )
                                        .frame(width: 28, height: 28)
                                }
                            }
                        }
                    }
                    
                    // 装饰性元素 - 更大更明显
                    HStack(spacing: 16) {
                        Circle().fill(Color.pink).frame(width: 14, height: 14)
                        Circle().fill(Color.orange).frame(width: 14, height: 14)
                        Circle().fill(Color.green).frame(width: 14, height: 14)
                    }
                }
                
                // 左下角装饰 - 代表时间流逝
                VStack {
                    Spacer()
                    HStack {
                        VStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: 3, height: CGFloat(8 + index * 6))
                                    .cornerRadius(1.5)
                            }
                        }
                        .padding(.leading, 40)
                        Spacer()
                    }
                }
                .frame(width: 650, height: 650)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

// 深色模式版本 - 现代图表风格
struct AppIconDesignChartDark: View {
    var body: some View {
        ZStack {
            // 深色渐变背景
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.3, blue: 0.25), // 深绿色
                    Color(red: 0.1, green: 0.4, blue: 0.3),    // 深绿色
                    Color(red: 0.15, green: 0.35, blue: 0.4)  // 深蓝绿色
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 1024, height: 1024)
            
            // 主设计元素
            ZStack {
                // 中心圆形背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.98), .white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 650, height: 650)
                    .shadow(color: .black.opacity(0.4), radius: 40, x: 0, y: 20)
                
                // 现代图表设计
                VStack(spacing: 25) {
                    // 图表标题 - 更大
                    Text("📊")
                        .font(.system(size: 60))
                    
                    // 现代柱状图 - 更大更清晰
                    HStack(alignment: .bottom, spacing: 18) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.9), Color.purple.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 35, height: 120)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 35, height: 180)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.9), Color.green.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 35, height: 150)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.9), Color.orange.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 35, height: 90)
                            .cornerRadius(6)
                    }
                    
                    // 装饰性元素 - 更大更明显
                    HStack(spacing: 12) {
                        Circle().fill(Color.purple).frame(width: 10, height: 10)
                        Circle().fill(Color.blue).frame(width: 10, height: 10)
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Circle().fill(Color.orange).frame(width: 10, height: 10)
                    }
                }
                
                // 右上角装饰 - 代表数据增长
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: CGFloat(4 + index * 2), height: 3)
                                    .cornerRadius(1.5)
                            }
                        }
                        .padding(.trailing, 40)
                    }
                    Spacer()
                }
                .frame(width: 650, height: 650)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview("图标设计 - 圆点风格") {
    AppIconDesign()
}


#Preview("图标设计 - 日历风格") {
    AppIconDesignCalendar()
}

#Preview("图标设计 - 图表风格") {
    AppIconDesignChart()
}

#Preview("图标设计 - 深色模式") {
    AppIconDesignDark()
}

#Preview("设计说明") {
    IconDesignNotes()
}
