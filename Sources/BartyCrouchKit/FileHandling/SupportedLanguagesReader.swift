import Foundation
import HandySwift
import SwiftSyntax

class SupportedLanguagesReader: SyntaxVisitor {
  let typeName: String
  var caseToLangCode: [String: String] = [:]

  init(
    typeName: String
  ) {
    self.typeName = typeName
  }

  override func visit(_ enumDeclaration: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
    if enumDeclaration.parent?.as(CodeBlockItemSyntax.self) != nil
      || enumDeclaration.identifier.text == "SupportedLanguage"
    {
      return .visitChildren
    }
    else {
      return .skipChildren
    }
  }

  override func visit(_ enumCaseElement: EnumCaseElementSyntax) -> SyntaxVisitorContinueKind {
    if let langCodeLiteral = enumCaseElement.rawValue?.value.as(StringLiteralExprSyntax.self) {
      caseToLangCode[enumCaseElement.identifier.text] = langCodeLiteral.text
    }

    return .skipChildren
  }
}
