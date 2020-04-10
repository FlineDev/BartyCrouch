import Foundation

struct TransformTaskHandler {
    let options: TransformOptions

    init(options: TransformOptions) {
        self.options = options
    }
}

extension TransformTaskHandler: TaskHandler {
    func perform() {
        measure(task: "Code Transform") {
            mungo.do {
                var caseToLangCodeOptional: [String: String]?

                for codeFile in CodeFilesSearch(baseDirectoryPath: options.supportedLanguageEnumPath.absolutePath).findCodeFiles() {
                    if let foundCaseToLangCode = CodeFileHandler(path: codeFile).findCaseToLangCodeMappings(typeName: options.typeName) {
                        caseToLangCodeOptional = foundCaseToLangCode
                        break
                    }
                }

                guard let caseToLangCode = caseToLangCodeOptional else {
                    print(
                        "Could not find 'SupportedLanguage' enum within '\(options.typeName)' enum within path.",
                        level: .warning,
                        file: options.supportedLanguageEnumPath.absolutePath
                    )
                    return
                }

                var translateEntries: [CodeFileHandler.TranslateEntry] = []

                for codeFile in CodeFilesSearch(baseDirectoryPath: options.codePath.absolutePath).findCodeFiles() {
                    let codeFileHandler = CodeFileHandler(path: codeFile)

                    translateEntries += try codeFileHandler.transform(
                        typeName: options.typeName,
                        translateMethodName: options.translateMethodName,
                        using: options.transformer,
                        caseToLangCode: caseToLangCode
                    )
                }

                let stringsFiles: [String] = StringsFilesSearch.shared.findAllStringsFiles(
                    within: options.localizablePath.absolutePath,
                    withFileName: options.customLocalizableName ?? "Localizable"
                )

                for stringsFile in stringsFiles {
                    StringsFileUpdater(path: stringsFile)!.insert(translateEntries: translateEntries)
                }
            }
        }
    }
}
