//
//  MonospaceDetector.swift
//  QlipX
//
//  Created by Codex on 29/05/2026.
//

import Foundation

struct MonospaceDetector {
    private static let patterns: [String] = [
        #"^\d{1,3}(\.\d{1,3}){3}(:\d+)?$"#,
        #"^(/[\w.\-]+){2,}$"#,
        #"^[a-zA-Z][a-zA-Z0-9+\-.]*://"#,
        #"^[0-9a-fA-F:]{17}$"#
    ]

    static func isMonospace(_ text: String) -> Bool {
        patterns.contains { pattern in
            text.range(of: pattern, options: .regularExpression) != nil
        }
    }
}
