@testable import BartyCrouchKit
import Toml
import XCTest

class ConfigurationTests: XCTestCase {
    func testConfigurationMakeDefault() {
        do {
            let configuration: Configuration = try Configuration.makeDefault()

            XCTAssertEqual(configuration.updateOptions.tasks, [.interfaces, .code, .transform, .normalize])

            XCTAssertEqual(configuration.updateOptions.interfaces.path, ".")
            XCTAssertEqual(configuration.updateOptions.interfaces.defaultToBase, false)
            XCTAssertEqual(configuration.updateOptions.interfaces.ignoreEmptyStrings, false)
            XCTAssertEqual(configuration.updateOptions.interfaces.unstripped, false)

            XCTAssertEqual(configuration.updateOptions.code.codePath, ".")
            XCTAssertEqual(configuration.updateOptions.code.localizablePath, ".")
            XCTAssertEqual(configuration.updateOptions.code.additive, true)
            XCTAssertEqual(configuration.updateOptions.code.customFunction, nil)
            XCTAssertEqual(configuration.updateOptions.code.customLocalizableName, nil)
            XCTAssertEqual(configuration.updateOptions.code.defaultToKeys, false)
            XCTAssertEqual(configuration.updateOptions.code.unstripped, false)

            XCTAssertEqual(configuration.updateOptions.transform.codePath, ".")
            XCTAssertEqual(configuration.updateOptions.transform.localizablePath, ".")
            XCTAssertEqual(configuration.updateOptions.transform.transformer, .foundation)
            XCTAssertEqual(configuration.updateOptions.transform.typeName, "BartyCrouch")
            XCTAssertEqual(configuration.updateOptions.transform.translateMethodName, "translate")
            XCTAssertEqual(configuration.updateOptions.transform.customLocalizableName, nil)

            XCTAssertEqual(configuration.updateOptions.normalize.path, ".")
            XCTAssertEqual(configuration.updateOptions.normalize.sourceLocale, "en")
            XCTAssertEqual(configuration.updateOptions.normalize.harmonizeWithSource, true)
            XCTAssertEqual(configuration.updateOptions.normalize.sortByKeys, true)

            XCTAssertNil(configuration.updateOptions.translate)

            XCTAssertEqual(configuration.lintOptions.path, ".")
            XCTAssertEqual(configuration.lintOptions.duplicateKeys, true)
            XCTAssertEqual(configuration.lintOptions.emptyValues, true)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testConfigurationMakeMostNonDefault() {
        let toml: Toml = try! Toml(
            withString: """
                [update]
                tasks = ["interfaces", "transform", "normalize"]

                [update.interfaces]
                path = "Sources"
                defaultToBase = true
                ignoreEmptyStrings = true
                unstripped = true

                [update.code]
                codePath = "Sources"
                localizablePath = "Sources/SupportingFiles"
                defaultToKeys = true
                additive = false
                customFunction = "MyOwnLocalizedString"
                customLocalizableName = "MyOwnLocalizable"
                unstripped = true

                [update.transform]
                codePath = "Sources"
                localizablePath = "Sources/SupportingFiles"
                transformer = "swiftgenStructured"
                supportedLanguageEnumPath = "Sources/SupportingFiles"
                typeName = "BC"
                translateMethodName = "t"
                customLocalizableName = "MyOwnLocalizable"

                [update.normalize]
                path = "Sources"
                sourceLocale = "de"
                harmonizeWithSource = false
                sortByKeys = false

                [update.translate]
                path = "Sources"
                api = "bing"
                id = "bingId"
                secret = "bingSecret"
                sourceLocale = "de"

                [lint]
                path = "Sources"
                duplicateKeys = false
                emptyValues = false

                """
        )

        do {
            let configuration: Configuration = try Configuration.make(toml: toml)

            XCTAssertEqual(configuration.updateOptions.tasks, [.interfaces, .transform, .normalize])

            XCTAssertEqual(configuration.updateOptions.interfaces.path, "Sources")
            XCTAssertEqual(configuration.updateOptions.interfaces.defaultToBase, true)
            XCTAssertEqual(configuration.updateOptions.interfaces.ignoreEmptyStrings, true)
            XCTAssertEqual(configuration.updateOptions.interfaces.unstripped, true)

            XCTAssertEqual(configuration.updateOptions.code.codePath, "Sources")
            XCTAssertEqual(configuration.updateOptions.code.localizablePath, "Sources/SupportingFiles")
            XCTAssertEqual(configuration.updateOptions.code.additive, false)
            XCTAssertEqual(configuration.updateOptions.code.customFunction, "MyOwnLocalizedString")
            XCTAssertEqual(configuration.updateOptions.code.customLocalizableName, "MyOwnLocalizable")
            XCTAssertEqual(configuration.updateOptions.code.defaultToKeys, true)
            XCTAssertEqual(configuration.updateOptions.code.unstripped, true)

            XCTAssertEqual(configuration.updateOptions.transform.codePath, "Sources")
            XCTAssertEqual(configuration.updateOptions.transform.localizablePath, "Sources/SupportingFiles")
            XCTAssertEqual(configuration.updateOptions.transform.transformer, .swiftgenStructured)
            XCTAssertEqual(configuration.updateOptions.transform.supportedLanguageEnumPath, "Sources/SupportingFiles")
            XCTAssertEqual(configuration.updateOptions.transform.typeName, "BC")
            XCTAssertEqual(configuration.updateOptions.transform.translateMethodName, "t")
            XCTAssertEqual(configuration.updateOptions.transform.customLocalizableName, "MyOwnLocalizable")

            XCTAssertEqual(configuration.updateOptions.normalize.path, "Sources")
            XCTAssertEqual(configuration.updateOptions.normalize.sourceLocale, "de")
            XCTAssertEqual(configuration.updateOptions.normalize.harmonizeWithSource, false)
            XCTAssertEqual(configuration.updateOptions.normalize.sortByKeys, false)

            XCTAssertEqual(configuration.updateOptions.translate!.path, "Sources")
            XCTAssertEqual(configuration.updateOptions.translate!.secret, "bingSecret")
            XCTAssertEqual(configuration.updateOptions.translate!.sourceLocale, "de")

            XCTAssertEqual(configuration.lintOptions.path, "Sources")
            XCTAssertEqual(configuration.lintOptions.duplicateKeys, false)
            XCTAssertEqual(configuration.lintOptions.emptyValues, false)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testConfigurationTomlContents() {
        let tomlContents: String = """
            [update]
            tasks = ["interfaces", "code", "transform"]

            [update.interfaces]
            path = "Sources"
            defaultToBase = true
            ignoreEmptyStrings = true
            unstripped = true

            [update.code]
            codePath = "Sources"
            localizablePath = "Sources/SupportingFiles"
            defaultToKeys = true
            additive = false
            customFunction = "MyOwnLocalizedString"
            customLocalizableName = "MyOwnLocalizable"
            unstripped = true

            [update.transform]
            codePath = "."
            localizablePath = "."
            transformer = "foundation"
            supportedLanguageEnumPath = "."
            typeName = "BartyCrouch"
            translateMethodName = "translate"

            [update.translate]
            path = "Sources"
            secret = "bingSecret"
            sourceLocale = "de"

            [update.normalize]
            path = "Sources"
            sourceLocale = "de"
            harmonizeWithSource = false
            sortByKeys = false

            [lint]
            path = "Sources"
            duplicateKeys = false
            emptyValues = false

            """
        let toml: Toml = try! Toml(withString: tomlContents)
        let configuration: Configuration = try! Configuration.make(toml: toml)

        XCTAssertEqual(configuration.tomlContents(), tomlContents)
    }
}
