import Foundation

public struct DiscordApplicationInfo: Codable {
    public let id: String
    public let name: String
    public let icon: String?
    public let description: String
    
    public func iconURL(size: Int = 256) -> URL? {
        guard let icon = icon else { return nil }
        return URL(string: "https://cdn.discordapp.com/app-icons/\(id)/\(icon).png?size=\(size)")
    }
}

public class DiscordAPI {
    public static let shared = DiscordAPI()
    
    private init() {}
    
    public func fetchApplicationInfo(clientId: String) async throws -> DiscordApplicationInfo {
        guard !clientId.isEmpty else {
            throw DiscordAPIError.invalidClientId
        }
        
        let url = URL(string: "https://discord.com/api/v10/applications/\(clientId)/rpc")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DiscordAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw DiscordAPIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let appInfo = try decoder.decode(DiscordApplicationInfo.self, from: data)
        
        return appInfo
    }
    
    public func fetchIconImage(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DiscordAPIError.imageDownloadFailed
        }
        
        return data
    }
}

public enum DiscordAPIError: LocalizedError {
    case invalidClientId
    case invalidResponse
    case httpError(statusCode: Int)
    case imageDownloadFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidClientId:
            return "Invalid Client ID"
        case .invalidResponse:
            return "Invalid response from Discord API"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .imageDownloadFailed:
            return "Failed to download image"
        }
    }
}
