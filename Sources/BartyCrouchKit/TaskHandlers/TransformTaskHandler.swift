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
                for codeFile in CodeFilesSearch(baseDirectoryPath: options.codePath).findCodeFiles() {
                    let codeFileUpdater = CodeFileUpdater(path: codeFile)

                    let translateEntries = try codeFileUpdater.transform(
                        typeName: options.typeName,
                        translateMethodName: options.translateMethodName,
                        using: options.transformer
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
