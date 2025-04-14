
public enum ESPError: Equatable {
    case failure(String)
    case success
    public static func == (lhs: ESPError, rhs: ESPError) -> Bool {
        switch (lhs, rhs) {
        case (.failure(let lhsMsg), .failure(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.success, .success):
            return true
        default:
            return false
        }
    }
}

func runEsp(_ command: () -> esp_err_t) -> ESPError {
    let err = command()
    guard err == ESP_OK else {
        if let s = esp_err_to_name(err) {
            return .failure("\(s)")
        } else { return .failure("Unknown error")}
    }
    return .success
}

