import Foundation

// 梦境解析服务 - 处理API调用和解析结果
class DreamAnalysisService {
    // API端点
    private let apiURL = "https://api.dreambuff.com/dream/analysis"
    
    // 解析结果模型
    struct DreamAnalysisResult: Codable {
        let analysis: String?
        let symbols: [String]?
        let sentiment_score: Double?
        let theme: String?
        let timestamp: String?
        
        // 错误信息处理
        var errorMessage: String?
        
        // 添加一个访问方法来获取格式化后的时间戳
        var formattedTimestamp: String? {
            guard let timestamp = timestamp else { return nil }
            
            let dateFormatter = ISO8601DateFormatter()
            if let date = dateFormatter.date(from: timestamp) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateStyle = .medium
                outputFormatter.timeStyle = .short
                return outputFormatter.string(from: date)
            }
            return nil
        }
    }
    
    // 解析梦境内容
    func analyzeDream(date: Date, content: String, completion: @escaping (Result<DreamAnalysisResult, Error>) -> Void) {
        // 准备请求参数
        let date = Date()
        let formatter = ISO8601DateFormatter()
        
        let parameters: [String: Any] = [
            "dream_content": content,
            "dream_date": formatter.string(from: date),
            "user_id": "1"
        ]
        
        // 创建请求
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("dream7289&3dsw", forHTTPHeaderField: "x-api-key")
        
        // 设置请求体
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }
        
        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 检查是否有错误
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // 确保有响应数据
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "DreamAnalysisService", code: 1, userInfo: [NSLocalizedDescriptionKey: "没有接收到数据"])))
                }
                return
            }
            
            // 打印接收到的JSON数据，用于调试
            if let jsonString = String(data: data, encoding: .utf8) {
                print("接收到的API响应: \(jsonString)")
            }
            
            // 解析响应
            do {
                let decoder = JSONDecoder()
                var result = try decoder.decode(DreamAnalysisResult.self, from: data)
                
                // 检查API返回的内容是否有效
                if result.analysis == nil {
                    result.errorMessage = "无法解析此梦境，请稍后再试"
                }
                
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                print("解析错误: \(error)")
                // 尝试获取API返回的错误信息
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["error"] as? String {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "DreamAnalysisService", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        
        // 启动任务
        task.resume()
    }
}
