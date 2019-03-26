// Created by Cihat Gündüz on 28.01.19.

import Foundation
import SwiftSyntax
import HandySwift

class SupportedLanguagesReader: SyntaxVisitor {
    let typeName: String
    var caseToLangCode: [String: String] = [:]

    init(typeName: String) {
        self.typeName = typeName
    }

    override func visit(_ enumDeclaration: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        guard enumDeclaration.identifier.text == "SupportedLanguage" else { return super.visit(enumDeclaration) }

        let enumCaseDeclarations: [EnumCaseDeclSyntax] = enumDeclaration.members.members.children.compactMap { $0 as? EnumCaseDeclSyntax }
        for enumCaseDeclaration in enumCaseDeclarations {
            let enumCaseElements: [EnumCaseElementSyntax] = enumCaseDeclaration.elements.children.compactMap { $0 as? EnumCaseElementSyntax }
            for enumCaseElement in enumCaseElements {
                let caseName = enumCaseElement.identifier.text
                if let langCodeLiteral = enumCaseElement.rawValue?.value as? StringLiteralExprSyntax {
                    caseToLangCode[caseName] = langCodeLiteral.text
                }
            }
        }

        return .skipChildren
    }
}
