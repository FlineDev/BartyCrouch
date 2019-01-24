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
                // TODO: read BartyCrouch enum and all it's cases raw values before visiting anything (static method)
                let caseToLangCode: [String: String] = ["english": "en", "german": "de"]

                for codeFile in CodeFilesSearch(baseDirectoryPath: options.codePath).findCodeFiles() {
                    let codeFileUpdater = CodeFileUpdater(path: codeFile)

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
