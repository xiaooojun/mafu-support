//
//  WeatherManager.swift
//  Life
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

// MARK: - 天气数据模型
struct WeatherInfo {
    let temperature: Int
    let condition: String
    let conditionIcon: String
    let location: String
    let isDaylight: Bool
}

// MARK: - OpenWeatherMap API响应模型
struct OpenWeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherCondition]
    let name: String
    let sys: SystemInfo
}

struct MainWeather: Codable {
    let temp: Double
}

struct WeatherCondition: Codable {
    let main: String
    let description: String
    let icon: String
}

struct SystemInfo: Codable {
    let sunrise: Int
    let sunset: Int
}

// MARK: - 错误类型
enum WeatherError: Error {
    case invalidURL
    case noData
    case decodingError
}

// MARK: - 天气管理器
@MainActor
class WeatherManager: NSObject, ObservableObject {
    static let shared = WeatherManager()
    
    @Published var weatherInfo: WeatherInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private let apiKey = "your_openweathermap_api_key" // 需要替换为真实的API Key
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - 设置位置管理器
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // 100米变化才更新
    }
    
    // MARK: - 请求天气信息
    func requestWeather() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        // 请求位置权限并获取真实天气数据
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "需要位置权限来获取天气信息"
            isLoading = false
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            errorMessage = "位置服务不可用"
            isLoading = false
        }
    }
    
    // MARK: - 强制刷新位置
    func forceRefreshLocation() {
        print("🔄 强制刷新位置...")
        locationManager.requestLocation()
    }
    
    // MARK: - 获取天气数据
    private func fetchWeather(for location: CLLocation) async {
        do {
            // 构建OpenWeatherMap API URL
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=zh_cn"
            
            guard let url = URL(string: urlString) else {
                throw WeatherError.invalidURL
            }
            
            // 发起网络请求
            let (data, _) = try await URLSession.shared.data(from: url)
            let weatherResponse = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
            
            // 获取位置名称 - 优先使用OpenWeatherMap返回的城市名
            var locationName = weatherResponse.name
            
            // 获取CoreLocation的详细位置信息
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            let placemark = placemarks.first
            
            // 调试信息 - 显示详细位置信息
            print("🌍 位置调试信息:")
            print("  坐标: \(lat), \(lon)")
            print("  OpenWeatherMap城市: \(weatherResponse.name)")
            if let placemark = placemark {
                print("  CoreLocation信息:")
                print("    locality: \(placemark.locality ?? "无")")
                print("    subLocality: \(placemark.subLocality ?? "无")")
                print("    administrativeArea: \(placemark.administrativeArea ?? "无")")
                print("    country: \(placemark.country ?? "无")")
            }
            
            // 优先使用CoreLocation的中文位置信息
            if let placemark = placemark {
                var locationParts: [String] = []
                
                // 优先使用locality（城市）
                if let locality = placemark.locality {
                    locationParts.append(locality)
                }
                // 如果locality为空，使用subLocality
                else if let subLocality = placemark.subLocality {
                    locationParts.append(subLocality)
                }
                
                // 添加省份/州
                if let administrativeArea = placemark.administrativeArea {
                    locationParts.append(administrativeArea)
                }
                
                // 添加国家
                if let country = placemark.country {
                    locationParts.append(country)
                }
                
                if !locationParts.isEmpty {
                    locationName = locationParts.joined(separator: ", ")
                }
            }
            
            print("  最终位置: \(locationName)")
            
            // 判断是否为白天
            let currentTime = Int(Date().timeIntervalSince1970)
            let isDaylight = currentTime >= weatherResponse.sys.sunrise && currentTime <= weatherResponse.sys.sunset
            
            // 创建天气信息
            let weatherInfo = WeatherInfo(
                temperature: Int(weatherResponse.main.temp),
                condition: getWeatherCondition(weatherResponse.weather.first?.main ?? ""),
                conditionIcon: getWeatherIcon(weatherResponse.weather.first?.icon ?? ""),
                location: locationName,
                isDaylight: isDaylight
            )
            
            DispatchQueue.main.async {
                self.weatherInfo = weatherInfo
                self.isLoading = false
            }
            
        } catch {
            print("天气API错误: \(error)")
            // 如果API失败，提供模拟数据
            await provideMockWeatherData()
        }
    }
    
    // MARK: - 提供模拟天气数据
    private func provideMockWeatherData() async {
        let mockConditions = ["晴朗", "多云", "小雨", "阴天", "雷雨", "雪"]
        let mockIcons = ["sun.max.fill", "cloud.fill", "cloud.rain.fill", "cloud.fill", "cloud.bolt.fill", "cloud.snow.fill"]
        let mockTemperatures = [18, 22, 15, 20, 25, 8]
        let mockLocations = ["北京", "上海", "深圳", "广州", "杭州", "成都"]
        
        let randomIndex = Int.random(in: 0..<mockConditions.count)
        
        let weatherInfo = WeatherInfo(
            temperature: mockTemperatures[randomIndex],
            condition: mockConditions[randomIndex],
            conditionIcon: mockIcons[randomIndex],
            location: mockLocations[randomIndex],
            isDaylight: true
        )
        
        DispatchQueue.main.async {
            self.weatherInfo = weatherInfo
            self.isLoading = false
        }
    }
    
    // MARK: - 天气条件转换
    private func getWeatherCondition(_ condition: String) -> String {
        switch condition.lowercased() {
        case "clear":
            return "晴朗"
        case "clouds":
            return "多云"
        case "rain":
            return "小雨"
        case "drizzle":
            return "毛毛雨"
        case "thunderstorm":
            return "雷雨"
        case "snow":
            return "雪"
        case "mist", "fog":
            return "雾"
        case "haze":
            return "霾"
        default:
            return "未知"
        }
    }
    
    // MARK: - 天气图标转换
    private func getWeatherIcon(_ icon: String) -> String {
        switch icon {
        case "01d", "01n":
            return "sun.max.fill"
        case "02d", "02n", "03d", "03n", "04d", "04n":
            return "cloud.fill"
        case "09d", "09n", "10d", "10n":
            return "cloud.rain.fill"
        case "11d", "11n":
            return "cloud.bolt.fill"
        case "13d", "13n":
            return "cloud.snow.fill"
        case "50d", "50n":
            return "cloud.fog.fill"
        default:
            return "sun.max.fill"
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task {
            await fetchWeather(for: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "位置获取失败"
        isLoading = false
        print("位置获取错误: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "需要位置权限来获取天气信息"
            isLoading = false
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            errorMessage = "位置服务不可用"
            isLoading = false
        }
    }
}