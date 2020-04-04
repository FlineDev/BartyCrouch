// Created by Cihat Gündüz on 24.01.19.

import Foundation
import SwiftSyntax
import HandySwift

class TranslateTransformer: SyntaxRewriter {
    let transformer: Transformer
    let typeName: String
    let translateMethodName: String
    let caseToLangCode: [String: String]

    var translateEntries: [CodeFileHandler.TranslateEntry] = []

    init(transformer: Transformer, typeName: String, translateMethodName: String, caseToLangCode: [String: String]) {
        self.transformer = transformer
        self.typeName = typeName
        self.translateMethodName = translateMethodName
        self.caseToLangCode = caseToLangCode
    }

    override func visit(_ functionCallExpression: FunctionCallExprSyntax) -> ExprSyntax {
        var functionCallExpressionIterator = functionCallExpression.children.makeIterator()
        
        guard
            let memberAccessExpression = functionCallExpressionIterator.next()?.as(MemberAccessExprSyntax.self), // 0
            let memberAccessExpressionBase = memberAccessExpression.base,
            memberAccessExpressionBase.description.stripped() == typeName,
            memberAccessExpression.name.text == translateMethodName
        else {
              return super.visit(functionCallExpression)
        }
        _ = functionCallExpressionIterator.next() // 1
        guard
            let functionCallArgumentList = functionCallExpressionIterator.next()?.as(TupleExprElementListSyntax.self) //2
        else {
            return super.visit(functionCallExpression)
        }
        var functionCallArgumentListIterator = functionCallArgumentList.children.makeIterator()
        
        guard
            let keyFunctionCallArgument = functionCallArgumentListIterator.next()?.as(TupleExprElementSyntax.self),
            let keyStringLiteralExpression = keyFunctionCallArgument.expression.as(StringLiteralExprSyntax.self),
            keyFunctionCallArgument.label?.text == "key",
            let translationsFunctionCallArgument = functionCallArgumentListIterator.next()?.as(TupleExprElementSyntax.self),
            translationsFunctionCallArgument.label?.text == "translations"
        else {
            return super.visit(functionCallExpression)
        }
        
        var translationsFunctionCallArgumentIterator = translationsFunctionCallArgument.children.makeIterator()
        _ = translationsFunctionCallArgumentIterator.next() // 0
        _ = translationsFunctionCallArgumentIterator.next() // 1
        
        guard
            let translationsDictionaryExpression = translationsFunctionCallArgumentIterator.next()?.as(DictionaryExprSyntax.self)
        else {
            return super.visit(functionCallExpression)
        }

        let leadingWhitespace: String = String(memberAccessExpressionBase.description.prefix(memberAccessExpressionBase.description.count - typeName.count))
        let key = keyStringLiteralExpression.text

        guard !key.isEmpty else {
            print("Found empty key in translate entry '\(functionCallExpression)'.", level: .warning)
            return ExprSyntax(functionCallExpression)
        }

        var translations: [CodeFileHandler.TranslationElement] = []

        var translationsDictionaryExpressionIterator = translationsDictionaryExpression.children.makeIterator()
        _ = translationsDictionaryExpressionIterator.next() // 0
        
        if let translationsDictionaryElementList = translationsDictionaryExpressionIterator.next()?.as(DictionaryElementListSyntax.self) {
            for dictionaryElement in translationsDictionaryElementList {
                guard let langCase = dictionaryElement.keyExpression.description.components(separatedBy: ".").last?.stripped() else {
                    print("LangeCase was not an enum case literal: '\(dictionaryElement.keyExpression)'")
                    return ExprSyntax(functionCallExpression)
                }

                guard let translationLiteralExpression = dictionaryElement.valueExpression.as(StringLiteralExprSyntax.self) else {
                    print("Translation for langCase '\(langCase)' was not a String literal: '\(dictionaryElement.valueExpression)'")
                    return ExprSyntax(functionCallExpression)
                }

                let translation = translationLiteralExpression.text

                guard !translation.isEmpty else {
                    print("Translation for langCase '\(langCase)' was empty.", level: .warning)
                    continue
                }

                guard let langCode = caseToLangCode[langCase] else {
                    print("Could not find a langCode for langCase '\(langCase)' when transforming translation.", level: .warning)
                    continue
                }

                translations.append((langCode: langCode, translation: translation))
            }
        }

        var comment: String?

        if
            let commentFunctionCallArgument = functionCallArgumentListIterator.next()?.as(TupleExprElementSyntax.self),
            commentFunctionCallArgument.label?.text == "comment",
            let commentStringLiteralExpression = commentFunctionCallArgument.expression.as(StringLiteralExprSyntax.self)
        {
            comment = commentStringLiteralExpression.text
        }

        let translateEntry: CodeFileHandler.TranslateEntry = (key: key, translations: translations, comment: comment)
        translateEntries.append(translateEntry)

        print("Found translate entry with key '\(key)' and \(translations.count) translations.", level: .info)

        let transformedExpression: ExprSyntax = {
            switch transformer {
            case .foundation:
                return buildFoundationExpression(key: key, comment: comment, leadingWhitespace: leadingWhitespace)

            case .swiftgenStructured:
                return buildSwiftgenStructuredExpression(key: key, leadingWhitespace: leadingWhitespace)
            }
        }()

        print("Transformed '\(functionCallExpression)' to '\(transformedExpression)'.", level: .info)

        return transformedExpression
    }

    private func buildSwiftgenStructuredExpression(key: String, leadingWhitespace: String) -> ExprSyntax {
        // e.g. the key could be something like 'ONBOARDING.FIRST_PAGE.HEADER_TITLE' or 'onboarding.first-page.header-title'
        let keywordSeparators: CharacterSet = CharacterSet(charactersIn: ".")
        let casingSeparators: CharacterSet = CharacterSet(charactersIn: "-_")

        // e.g. ["ONBOARDING", "FIRST_PAGE", "HEADER_TITLE"]
        let keywords: [String] = key.components(separatedBy: keywordSeparators)

        // e.g. [["ONBOARDING"], ["FIRST", "PAGE"], ["HEADER", "TITLE"]]
        let keywordsCasingComponents: [[String]] = keywords.map { $0.components(separatedBy: casingSeparators) }

        // e.g. ["Onboarding", "FirstPage", "HeaderTitle"]
        var swiftgenKeyComponents: [String] = keywordsCasingComponents.map { $0.map { $0.capitalized }.joined() }

        // e.g. ["Onboarding", "FirstPage", "headerTitle"]
        let lastKeyComponentIndex: Int = swiftgenKeyComponents.endIndex - 1
        swiftgenKeyComponents[lastKeyComponentIndex] = swiftgenKeyComponents[lastKeyComponentIndex].firstCharacterLowercased()

        // e.g. ["L10n", "Onboarding", "FirstPage", "headerTitle"]
        swiftgenKeyComponents.insert("\(leadingWhitespace)L10n", at: 0)

        return buildMemberAccessExpression(components: swiftgenKeyComponents)
    }

    private func buildMemberAccessExpression(components: [String]) -> ExprSyntax {
        let identifierToken = SyntaxFactory.makeIdentifier(components.last!)
        guard components.count > 1 else { return ExprSyntax(SyntaxFactory.makeIdentifierExpr(identifier: identifierToken, declNameArguments: nil)) }
        return ExprSyntax(SyntaxFactory.makeMemberAccessExpr(
            base: buildMemberAccessExpression(components: Array(components.dropLast())),
            dot: SyntaxFactory.makePeriodToken(),
            name: identifierToken,
            declNameArguments: nil
        ))
    }

    private func buildFoundationExpression(key: String, comment: String?, leadingWhitespace: String) -> ExprSyntax {
        let keyArgument = SyntaxFactory.makeTupleExprElement(
            label: nil,
            colon: nil,
            expression: ExprSyntax(SyntaxFactory.makeStringLiteralExpr(key)),
            trailingComma: SyntaxFactory.makeCommaToken(leadingTrivia: .zero, trailingTrivia: .spaces(1))
        )

        let commentArgument = SyntaxFactory.makeTupleExprElement(
            label: SyntaxFactory.makeIdentifier("comment"),
            colon: SyntaxFactory.makeColonToken(leadingTrivia: .zero, trailingTrivia: .spaces(1)),
            expression: ExprSyntax(SyntaxFactory.makeStringLiteralExpr(comment ?? "")),
            trailingComma: nil
        )

        return ExprSyntax(SyntaxFactory.makeFunctionCallExpr(
            calledExpression: ExprSyntax(SyntaxFactory.makeIdentifierExpr(identifier: SyntaxFactory.makeIdentifier("\(leadingWhitespace)NSLocalizedString"), declNameArguments: nil)),
            leftParen: SyntaxFactory.makeLeftParenToken(),
            argumentList: SyntaxFactory.makeTupleExprElementList([keyArgument, commentArgument]),
            rightParen: SyntaxFactory.makeRightParenToken(),
            trailingClosure: nil
        ))
    }
}

extension StringLiteralExprSyntax {
    var text: String {
        let description: String = self.description
        guard description.count > 2 else { return "" }

        let textRange = description.index(description.startIndex, offsetBy: 1) ..< description.index(description.endIndex, offsetBy: -1)
        return String(description[textRange])
    }
}
