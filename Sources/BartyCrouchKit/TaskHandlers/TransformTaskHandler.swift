import Foundation

struct TransformTaskHandler {
    let options: TransformOptions

    init(options: TransformOptions) {
        self.options = options
    }
}

extension TransformTaskHandler: TaskHandler {
    func perform() {
        measure(task: "Update Code Transform") {
            mungo.do {
                var caseToLangCodeOptional: [String: String]?

                for codeFile in CodeFilesSearch(baseDirectoryPath: options.supportedLanguageEnumPath).findCodeFiles() {
                    if let foundCaseToLangCode = CodeFileHandler(path: codeFile).findCaseToLangCodeMappings(typeName: options.typeName) {
                        caseToLangCodeOptional = foundCaseToLangCode
                        break
                    }
                }

                guard let caseToLangCode = caseToLangCodeOptional else {
                    print("Could not find 'SupportedLanguage' enum within '\(options.typeName)' enum within path.", level: .warning, file: options.supportedLanguageEnumPath)
                    return
                }

                for codeFile in CodeFilesSearch(baseDirectoryPath: options.codePath).findCodeFiles() {
                    let codeFileUpdater = CodeFileHandler(path: codeFile)

                    let translateEntries = try codeFileUpdater.transform(
                        typeName: options.typeName,
                        translateMethodName: options.translateMethodName,
                        using: options.transformer,
                        caseToLangCode: caseToLangCode
                    )

                    let stringsFiles: [String] = StringsFilesSearch.shared.findAllStringsFiles(
                        within: options.localizablePath,
                        withFileName: options.customLocalizableName ?? "Localizable"
                    )

                    for stringsFile in stringsFiles {
                        StringsFileUpdater(path: stringsFile)!.insert(translateEntries: translateEntries)
                    }
                }
            }
        }
    }
}
