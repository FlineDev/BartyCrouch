// Created by Cihat Gündüz on 24.01.19.

import Foundation
import SwiftSyntax

class TranslateTransformer: SyntaxRewriter {
    let transformer: Transformer
    let typeName: String
    let translateMethodName: String
    var translateEntries: [CodeFileUpdater.TranslateEntry] = []

    init(transformer: Transformer, typeName: String, translateMethodName: String) {
        self.transformer = transformer
        self.typeName = typeName
        self.translateMethodName = translateMethodName
    }

    override func visit(_ node: TokenSyntax) -> Syntax {
        // TODO: not yet implemented
        print("Found token \(node)")
        return node
    }

    override func visit(_ node: DeclListSyntax) -> Syntax {
        // TODO: not yet implemented
        print("Found declList \(node)")
        return node
    }

    override func visit(_ node: EnumDeclSyntax) -> DeclSyntax {
        // TODO: not yet implemented
        print("Found enumDecl \(node)")
        return node
    }

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        // TODO: not yet implemented
        print("Found classDecl \(node)")
        return node
    }

    override func visit(_ node: TypeAnnotationSyntax) -> Syntax {
        // TODO: not yet implemented
        print("Found typeAnnotation \(node)")
        return node
    }
}
