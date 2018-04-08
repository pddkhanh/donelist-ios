//
//  Logger.swift
//  DoneList
//
//  Created by Khanh Pham on 30/3/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation
import CocoaLumberjack

public class LogFormatter: NSObject, DDLogFormatter {

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS Z"
        return formatter
    }()

    public func format(message logMessage: DDLogMessage) -> String? {
        return String(format: "%@ %@:%d %@", formatter.string(from: logMessage.timestamp),
                      (logMessage.file as NSString).lastPathComponent, logMessage.line, logMessage.message)
    }
}

public class Logger: NSObject {

    public static let shared = Logger()
    private let fileLogger: DDFileLogger

    private override init() {
        fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 2
    }

    public func configure() {
        DDTTYLogger.sharedInstance.logFormatter = LogFormatter()
        DDLog.add(DDTTYLogger.sharedInstance) // TTY = Xcode console

        fileLogger.logFormatter = LogFormatter()
        DDLog.add(fileLogger)
    }

    public func getLogText(_ handler: @escaping (String) -> Void) {
        getLogData { (data) in
            let log = String(data: data, encoding: .utf8) ?? ""
            DispatchQueue.main.async {
                handler(log)
            }
        }
    }

    public func cleanLogs(_ handler: @escaping () -> Void) {
        fileLogger.rollLogFile { [weak self] in
            guard let weakSelf = self else { return }
            do {
                try weakSelf.fileLogger.logFileManager.unsortedLogFilePaths
                    .forEach({ (path) in
                        try FileManager.default.removeItem(atPath: path)
                    })
            } catch {
                print("Failed to remove log file: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                handler()
            }
        }
    }

    public func getLogData(_ handler: @escaping (Data) -> Void) {
        fileLogger.rollLogFile { [weak self] in
            guard let weakSelf = self else { return }
            let result = NSMutableData()
            do {
                try weakSelf.fileLogger.logFileManager.sortedLogFilePaths.reversed()
                    .compactMap { URL(fileURLWithPath: $0) }
                    .map { try Data(contentsOf: $0) }
                    .forEach { data in
                        result.append(data)
                }
            } catch {
                print("Failed to get log data: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                handler(result as Data)
            }
        }
    }

    public func logDebug(_ message: @autoclosure () -> String, file: StaticString = #file,
                         function: StaticString = #function,
                         line: UInt = #line) {
        DDLogDebug(message, file: file, function: function, line: line)
    }

    public func logError(_ message: @autoclosure () -> String) {
        DDLogError(message)
    }

    public func logInfo(_ message: @autoclosure () -> String) {
        DDLogInfo(message)
    }

    public func logVerbose(_ message: @autoclosure () -> String) {
        DDLogVerbose(message)
    }

    public func logWarn(_ message: @autoclosure () -> String) {
        DDLogWarn(message)
    }
}

// MARK: - Convenient methods

public func logDebug(_ message: @autoclosure () -> String, file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
    Logger.shared.logDebug(message, file: file, function: function, line: line)
}

public func logError(_ message: @autoclosure () -> String) {
    Logger.shared.logError(message)
}

public func logInfo(_ message: @autoclosure () -> String) {
    Logger.shared.logInfo(message)
}

public func logVerbose(_ message: @autoclosure () -> String) {
    Logger.shared.logVerbose(message)
}

public func logWarn(_ message: @autoclosure () -> String) {
    Logger.shared.logWarn(message)
}
