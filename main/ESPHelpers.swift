
public enum ESPError {
    case failure(String)
    case success
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

