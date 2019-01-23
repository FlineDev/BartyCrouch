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
                for codeFile in CodeFilesSearch(directory: options.codePath).findCodeFiles() {
                    let codeFileUpdater = CodeFileUpdater(path: codeFile)

                    let translationEntries = codeFileUpdater.findTranslateEntries(
                        typeName: options.typeName,
                        translateMethodName: options.translateMethodName
                    )

                    let stringsFiles: [String] = StringsFilesSearch.shared.findAllStringsFiles(
                        within: options.localizablePath,
                        withFileName: options.customLocalizableName ?? "Localizable"
                    )

                    for stringsFile in stringsFiles {
                        StringsFileUpdater(path: stringsFile)!.insert(translateEntries: translationEntries)
                    }

                    codeFileUpdater.transform(translateEntries: translationEntries, using: options.transformer)
                }
            }
        }
    }
}
