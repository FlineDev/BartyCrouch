@testable import BartyCrouchConfiguration
import BartyCrouchUtility
import CustomDump
import Toml
import XCTest

// swiftlint:disable force_try function_body_length

class ConfigurationTests: XCTestCase {
  func testConfigurationMakeDefault() {
    do {
      let configuration: Configuration = try Configuration.makeDefault()

      XCTAssertEqual(configuration.updateOptions.tasks, [.interfaces, .code, .transform, .normalize])

      XCTAssertEqual(configuration.updateOptions.interfaces.paths, ["."])
      XCTAssertEqual(configuration.updateOptions.interfaces.defaultToBase, false)
      XCTAssertEqual(configuration.updateOptions.interfaces.ignoreEmptyStrings, false)
      XCTAssertEqual(configuration.updateOptions.interfaces.unstripped, false)

      XCTAssertEqual(configuration.updateOptions.code.codePaths, ["."])
      XCTAssertEqual(configuration.updateOptions.code.localizablePaths, ["."])
      XCTAssertEqual(configuration.updateOptions.code.additive, true)
      XCTAssertEqual(configuration.updateOptions.code.customFunction, nil)
      XCTAssertEqual(configuration.updateOptions.code.customLocalizableName, nil)
      XCTAssertEqual(configuration.updateOptions.code.defaultToKeys, false)
      XCTAssertEqual(configuration.updateOptions.code.unstripped, false)

      XCTAssertEqual(configuration.updateOptions.transform.codePaths, ["."])
      XCTAssertEqual(configuration.updateOptions.transform.localizablePaths, ["."])
      XCTAssertEqual(configuration.updateOptions.transform.transformer, .foundation)
      XCTAssertEqual(configuration.updateOptions.transform.typeName, "BartyCrouch")
      XCTAssertEqual(configuration.updateOptions.transform.translateMethodName, "translate")
      XCTAssertEqual(configuration.updateOptions.transform.customLocalizableName, nil)

      XCTAssertEqual(configuration.updateOptions.normalize.paths, ["."])
      XCTAssertEqual(configuration.updateOptions.normalize.sourceLocale, "en")
      XCTAssertEqual(configuration.updateOptions.normalize.harmonizeWithSource, true)
      XCTAssertEqual(configuration.updateOptions.normalize.sortByKeys, true)

      XCTAssertNil(configuration.updateOptions.translate)

      XCTAssertEqual(configuration.lintOptions.paths, ["."])
      XCTAssertEqual(configuration.lintOptions.duplicateKeys, true)
      XCTAssertEqual(configuration.lintOptions.emptyValues, true)
    }
    catch {
      XCTFail(error.localizedDescription)
    }
  }

  func testConfigurationMakeMostNonDefault() {
    let toml: Toml = try! Toml(
      withString: """
        [update]
        tasks = ["interfaces", "transform", "normalize"]

        [update.interfaces]
        paths = ["Sources/ViewA", "Sources/ViewB"]
        defaultToBase = true
        ignoreEmptyStrings = true
        unstripped = true

        [update.code]
        codePaths = ["Sources"]
        localizablePaths = ["Sources/SupportingFiles"]
        defaultToKeys = true
        additive = false
        customFunction = "MyOwnLocalizedString"
        customLocalizableName = "MyOwnLocalizable"
        unstripped = true

        [update.transform]
        codePaths = ["Sources"]
        localizablePaths = ["Sources/SupportingFiles"]
        transformer = "swiftgenStructured"
        supportedLanguageEnumPath = "Sources/SupportingFiles"
        typeName = "BC"
        translateMethodName = "t"
        customLocalizableName = "MyOwnLocalizable"

        [update.normalize]
        paths = ["Sources"]
        sourceLocale = "de"
        harmonizeWithSource = false
        sortByKeys = false

        [update.translate]
        paths = ["Sources"]
        api = "bing"
        id = "bingId"
        secret = "bingSecret"
        sourceLocale = "de"

        [lint]
        paths = ["Sources"]
        duplicateKeys = false
        emptyValues = false

        """
    )

    do {
      let configuration: Configuration = try Configuration.make(toml: toml)

      XCTAssertEqual(configuration.updateOptions.tasks, [.interfaces, .transform, .normalize])

      XCTAssertEqual(configuration.updateOptions.interfaces.paths, ["Sources/ViewA", "Sources/ViewB"])
      XCTAssertEqual(configuration.updateOptions.interfaces.defaultToBase, true)
      XCTAssertEqual(configuration.updateOptions.interfaces.ignoreEmptyStrings, true)
      XCTAssertEqual(configuration.updateOptions.interfaces.unstripped, true)

      XCTAssertEqual(configuration.updateOptions.code.codePaths, ["Sources"])
      XCTAssertEqual(configuration.updateOptions.code.localizablePaths, ["Sources/SupportingFiles"])
      XCTAssertEqual(configuration.updateOptions.code.additive, false)
      XCTAssertEqual(configuration.updateOptions.code.customFunction, "MyOwnLocalizedString")
      XCTAssertEqual(configuration.updateOptions.code.customLocalizableName, "MyOwnLocalizable")
      XCTAssertEqual(configuration.updateOptions.code.defaultToKeys, true)
      XCTAssertEqual(configuration.updateOptions.code.unstripped, true)

      XCTAssertEqual(configuration.updateOptions.transform.codePaths, ["Sources"])
      XCTAssertEqual(configuration.updateOptions.transform.localizablePaths, ["Sources/SupportingFiles"])
      XCTAssertEqual(configuration.updateOptions.transform.transformer, .swiftgenStructured)
      XCTAssertEqual(configuration.updateOptions.transform.supportedLanguageEnumPath, "Sources/SupportingFiles")
      XCTAssertEqual(configuration.updateOptions.transform.typeName, "BC")
      XCTAssertEqual(configuration.updateOptions.transform.translateMethodName, "t")
      XCTAssertEqual(configuration.updateOptions.transform.customLocalizableName, "MyOwnLocalizable")

      XCTAssertEqual(configuration.updateOptions.normalize.paths, ["Sources"])
      XCTAssertEqual(configuration.updateOptions.normalize.sourceLocale, "de")
      XCTAssertEqual(configuration.updateOptions.normalize.harmonizeWithSource, false)
      XCTAssertEqual(configuration.updateOptions.normalize.sortByKeys, false)

      XCTAssertEqual(configuration.updateOptions.translate!.paths, ["Sources"])
      XCTAssertEqual(configuration.updateOptions.translate!.secret, Secret.microsoftTranslator(secret: "bingSecret"))
      XCTAssertEqual(configuration.updateOptions.translate!.sourceLocale, "de")

      XCTAssertEqual(configuration.lintOptions.paths, ["Sources"])
      XCTAssertEqual(configuration.lintOptions.duplicateKeys, false)
      XCTAssertEqual(configuration.lintOptions.emptyValues, false)
    }
    catch {
      XCTFail(error.localizedDescription)
    }
  }

  func testConfigurationTomlContents() {
    let tomlContents: String = """
      [update]
      tasks = ["interfaces", "code", "transform"]

      [update.interfaces]
      paths = ["Sources"]
      subpathsToIgnore = [".git", "carthage", "pods", "build", ".build", "docs"]
      defaultToBase = true
      ignoreEmptyStrings = true
      unstripped = true
      ignoreKeys = ["#bartycrouch-ignore!", "#bc-ignore!", "#i!"]

      [update.code]
      codePaths = ["Sources"]
      subpathsToIgnore = [".git", "carthage", "pods", "build", ".build", "docs"]
      localizablePaths = ["Sources/SupportingFiles"]
      defaultToKeys = true
      additive = false
      customFunction = "MyOwnLocalizedString"
      customLocalizableName = "MyOwnLocalizable"
      unstripped = true
      plistArguments = true
      ignoreKeys = ["#bartycrouch-ignore!", "#bc-ignore!", "#i!"]

      [update.transform]
      codePaths = ["."]
      subpathsToIgnore = [".git", "carthage", "pods", "build", ".build", "docs"]
      localizablePaths = ["."]
      transformer = "foundation"
      supportedLanguageEnumPath = "."
      typeName = "BartyCrouch"
      translateMethodName = "translate"
      separateWithEmptyLine = true

      [update.translate]
      paths = ["Sources"]
      subpathsToIgnore = [".git", "carthage", "pods", "build", ".build", "docs"]
      secret = "bingSecret"
      sourceLocale = "de"
      separateWithEmptyLine = true

      [update.normalize]
      paths = ["Sources"]
      subpathsToIgnore = [".git", "carthage", "pods", "build", ".build", "docs"]
      sourceLocale = "de"
      harmonizeWithSource = false
      sortByKeys = false
      separateWithEmptyLine = true

      [lint]
      paths = ["Sources"]
      subpathsToIgnore = [".git", "carthage", "pods", "build", ".build", "docs"]
      duplicateKeys = false
      emptyValues = false

      """
    let toml: Toml = try! Toml(withString: tomlContents)
    let configuration: Configuration = try! Configuration.make(toml: toml)

    XCTAssertNoDifference(tomlContents, configuration.tomlContents())
  }
}
