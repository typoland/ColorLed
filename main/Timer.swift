//
//  Timer.swift
//
//
//  Created by Łukasz Dziedzic on 07/04/2025.
//

//import CESP_IDF

final class Timer {
    enum TimerError: Swift.Error {
        case failedToAllocateMemoryForCString
        case failedToCreateTimer(String)
        case timerHasNoHandle
    }
    private var handle: esp_timer_handle_t?
    private var nameCString: UnsafePointer<CChar>?
    /// Create a periodic timer.
    /// - Parameters:
    ///   - name: Optional name for debug
    ///   - callback: Swift closure called on every tick
    init(name: String = "swift_timer",
         callback: @escaping () -> Void) 
    throws (Timer.TimerError) {
        
        let unmanaged = Unmanaged.passRetained(CallbackBox(callback))
        
        guard let namePtr = name.withCString({ strdup($0).map { UnsafePointer<CChar>($0) } }) else {
            throw(TimerError.failedToAllocateMemoryForCString)
        }
        self.nameCString = namePtr
        
        var args = esp_timer_create_args_t(
            callback: { ptr in
                if let box = ptr.map({ Unmanaged<CallbackBox>.fromOpaque($0).takeUnretainedValue() }) {
                    box.callback()
                }
            },
            arg: UnsafeMutableRawPointer(Unmanaged.passUnretained(unmanaged.takeUnretainedValue()).toOpaque()),
            dispatch_method: ESP_TIMER_TASK,
            name: nameCString,
            skip_unhandled_events: false
        )
        
        switch runEsp({esp_timer_create(&args, &handle)}) {
            case .failure(let error): throw .failedToCreateTimer(error)
            default: break
        }
    }
    
    func start(intervalMs: UInt64) {
        esp_timer_start_periodic(handle, intervalMs * 1000)  // convert ms to µs
    }
    
    func stop() {
        esp_timer_stop(handle)
    }
    
    func changeInterval(to newMs: UInt64) throws {
        guard let handle else {
            throw TimerError.timerHasNoHandle}
        esp_timer_stop(handle)
        esp_timer_start_periodic(handle, newMs * 1000)
    }
    
    deinit {
        if let handle = handle {
            esp_timer_stop(handle)
            esp_timer_delete(handle)
        }
        
        free(UnsafeMutablePointer(mutating: nameCString))  // Free at deinit
        
    }
    
    /// Internal wrapper to bridge Swift closure into C callback
    private final class CallbackBox {
        let callback: () -> Void
        init(_ callback: @escaping () -> Void) {
            self.callback = callback
        }
    }
}

