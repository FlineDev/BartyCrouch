// Created by Cihat Gündüz on 23.01.19.

import Foundation
import SwiftSyntax

final class CodeFileHandler {
    typealias TranslationElement = (langCode: String, translation: String)
    typealias TranslateEntry = (key: String, translations: [TranslationElement], comment: String?)

    private let path: String

    init(path: String) {
        self.path = path
    }

    /// Rewrites the file using the transformer. Returns the translate entries which were found (and transformed).
    func transform(typeName: String, translateMethodName: String, using transformer: Transformer, caseToLangCode: [String: String]) throws -> [TranslateEntry] {
        let fileUrl = URL(fileURLWithPath: path)
        guard try String(contentsOfFile: path).contains("\(typeName).\(translateMethodName)") else { return [] }

        guard let sourceFile = try? SyntaxTreeParser.parse(fileUrl) else {
            print("Could not parse syntax tree of Swift file.", level: .warning, file: path)
            return []
        }

        let translateTransformer = TranslateTransformer(
            transformer: transformer,
            typeName: typeName,
            translateMethodName: translateMethodName,
            caseToLangCode: caseToLangCode
        )
        let transformedFile: SourceFileSyntax = translateTransformer.visit(sourceFile) as! SourceFileSyntax

        try transformedFile.description.write(toFile: path, atomically: true, encoding: .utf8)
        return translateTransformer.translateEntries
    }

    func findCaseToLangCodeMappings(typeName: String) -> [String: String]? {
        let fileUrl = URL(fileURLWithPath: path)

        guard let sourceFile = try? SyntaxTreeParser.parse(fileUrl) else {
            print("Could not parse syntax tree of Swift file.", level: .warning, file: path)
            return nil
        }

        let supportedLanguagesReader = SupportedLanguagesReader(typeName: typeName)
        supportedLanguagesReader.visit(sourceFile)

        guard !supportedLanguagesReader.caseToLangCode.isEmpty else { return nil }
        return supportedLanguagesReader.caseToLangCode
    }
}
