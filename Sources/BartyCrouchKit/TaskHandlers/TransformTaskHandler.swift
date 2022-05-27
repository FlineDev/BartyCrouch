import BartyCrouchConfiguration
import Foundation

struct TransformTaskHandler {
  let options: TransformOptions
}

extension TransformTaskHandler: TaskHandler {
  func perform() {
    measure(task: "Code Transform") {
      mungo.do {
        var caseToLangCodeOptional: [String: String]?

        let codeFilesArray = CodeFilesSearch(baseDirectoryPath: options.supportedLanguageEnumPath.absolutePath)
          .findCodeFiles(subpathsToIgnore: options.subpathsToIgnore)

        for codeFile in codeFilesArray {
          if let foundCaseToLangCode = CodeFileHandler(path: codeFile)
            .findCaseToLangCodeMappings(typeName: options.typeName)
          {
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

        let codeFilesSet = Set(
          options.codePaths.flatMap {
            CodeFilesSearch(baseDirectoryPath: $0.absolutePath)
              .findCodeFiles(subpathsToIgnore: options.subpathsToIgnore)
          }
        )

        for codeFile in codeFilesSet {
          let codeFileHandler = CodeFileHandler(path: codeFile)

          translateEntries += try codeFileHandler.transform(
            typeName: options.typeName,
            translateMethodName: options.translateMethodName,
            using: options.transformer,
            caseToLangCode: caseToLangCode
          )
        }

        let stringsFiles: [String] = Array(
          Set(
            options.localizablePaths.flatMap {
              StringsFilesSearch.shared.findAllStringsFiles(
                within: $0.absolutePath,
                withFileName: options.customLocalizableName ?? "Localizable",
                subpathsToIgnore: options.subpathsToIgnore
              )
            }
          )
        )

        for stringsFile in stringsFiles {
          StringsFileUpdater(path: stringsFile)!
            .insert(
              translateEntries: translateEntries,
              separateWithEmptyLine: self.options.separateWithEmptyLine
            )
        }
      }
    }
  }
}
