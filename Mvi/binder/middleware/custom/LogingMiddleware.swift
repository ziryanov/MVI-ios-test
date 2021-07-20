//
//  LogingMiddleware.swift
//  MVI-ios-test
//
//  Created by ziryanov on 19.07.2021.
//

import Foundation

final public class LogingMiddleware: MiddlewareProtocol {
    private let config: Config
    private var consoleLogger = ConsoleLogger()
    
    init(_ config: Config = Config()) {
        self.config = config
    }
    
    init(_ changeConfig: (Config) -> Config) {
        self.config = changeConfig(Config())
    }
    
    public struct Config {
        var tag = "LoggingMiddleware"
        var onBindTemplate = "Binding %@"
        var onElementTemplate = "New element on %@: [%@]"
        var onCompleteTemplate = "Unbinding %@"
    }
    
    
    private func log(_ message: String) {
        dump("\(config.tag): \(message)", to: &consoleLogger)
        consoleLogger.flush()
    }
    
    public func onBind<Out, In>(_ connection: Connection<Out, In>) {
        log("Binding \(connection)")
    }
    
    public func onElement<Out, In>(_ connection: Connection<Out, In>, _ element: In) {
        log(String(format: config.onElementTemplate, String(describing: connection), String(describing: element)))
    }
    
    public func onComplete<Out, In>(_ connection: Connection<Out, In>) {
        log(String(format: config.onCompleteTemplate, String(describing: connection)))
    }
}

class ConsoleLogger: TextOutputStream {
    var buffer = ""

    func flush() {
        print(buffer)
        buffer = ""
    }

    func write(_ string: String) {
        buffer += string
    }
}
