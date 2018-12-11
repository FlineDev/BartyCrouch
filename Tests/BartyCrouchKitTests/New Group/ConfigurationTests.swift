@testable import BartyCrouchKit
import Toml
import XCTest

class ConfigurationTests: XCTestCase {
    func testConfigurationMakeDefault() {
        let toml: Toml = try! Toml(withString: "")

        do {
            let configuration: Configuration = try Configuration.make(toml: toml)

            XCTAssertEqual(configuration.updateOptions.interfaces.defaultToBase, false)
            XCTAssertEqual(configuration.updateOptions.interfaces.ignoreEmptyString, false)
            XCTAssertEqual(configuration.updateOptions.interfaces.unstripped, false)

            XCTAssertEqual(configuration.updateOptions.code.additive, true)
            XCTAssertEqual(configuration.updateOptions.code.customFunction, nil)
            XCTAssertEqual(configuration.updateOptions.code.customLocalizableName, nil)
            XCTAssertEqual(configuration.updateOptions.code.defaultToKeys, false)
            XCTAssertEqual(configuration.updateOptions.code.unstripped, false)

            XCTAssertEqual(configuration.updateOptions.normalize.sourceLocale, "en")
            XCTAssertEqual(configuration.updateOptions.normalize.harmonizeWithSource, true)
            XCTAssertEqual(configuration.updateOptions.normalize.sortByKeys, true)

            XCTAssertNil(configuration.updateOptions.translate)

            XCTAssertEqual(configuration.lintOptions.duplicateKeys, true)
            XCTAssertEqual(configuration.lintOptions.emptyValues, true)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testConfigurationMakeMostNonDefault() {
        let toml: Toml = try! Toml(
            withString: """
                [global]
                sourceLocale = "de"
                unstripped = true

                [update.interfaces]
                defaultToBase = true
                ignoreEmptyString = true
                unstripped = true

                [update.code]
                additive = false
                customFunction = "MyOwnLocalizedString"
                customLocalizableName = "MyOwnLocalizable"
                defaultToKeys = true
                unstripped = true

                [update.normalize]
                sourceLocale = "de"
                harmonizeWithSource = false
                sortByKeys = false

                [update.translate]
                api = "bing"
                id = "bingId"
                secret = "bingSecret"

                [lint]
                duplicateKeys = false
                emptyValues = false

                """
        )

        do {
            let configuration: Configuration = try Configuration.make(toml: toml)

            XCTAssertEqual(configuration.updateOptions.interfaces.defaultToBase, true)
            XCTAssertEqual(configuration.updateOptions.interfaces.ignoreEmptyString, true)
            XCTAssertEqual(configuration.updateOptions.interfaces.unstripped, true)

            XCTAssertEqual(configuration.updateOptions.code.additive, false)
            XCTAssertEqual(configuration.updateOptions.code.customFunction, "MyOwnLocalizedString")
            XCTAssertEqual(configuration.updateOptions.code.customLocalizableName, "MyOwnLocalizable")
            XCTAssertEqual(configuration.updateOptions.code.defaultToKeys, true)
            XCTAssertEqual(configuration.updateOptions.code.unstripped, true)

            XCTAssertEqual(configuration.updateOptions.normalize.sourceLocale, "de")
            XCTAssertEqual(configuration.updateOptions.normalize.harmonizeWithSource, false)
            XCTAssertEqual(configuration.updateOptions.normalize.sortByKeys, false)

            XCTAssertEqual(configuration.updateOptions.translate!.api.rawValue, "bing")
            XCTAssertEqual(configuration.updateOptions.translate!.id, "bingId")
            XCTAssertEqual(configuration.updateOptions.translate!.secret, "bingSecret")

            XCTAssertEqual(configuration.lintOptions.duplicateKeys, false)
            XCTAssertEqual(configuration.lintOptions.emptyValues, false)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testConfigurationTomlContents() {
        let tomlContents: String = """
            [update.interfaces]
            defaultToBase = true
            ignoreEmptyString = true
            unstripped = true

            [update.code]
            defaultToKeys = true
            additive = false
            customFunction = "MyOwnLocalizedString"
            customLocalizableName = "MyOwnLocalizable"
            unstripped = true

            [update.translate]
            api = "bing"
            id = "bingId"
            secret = "bingSecret"

            [update.normalize]
            sourceLocale = "de"
            harmonizeWithSource = false
            sortByKeys = false

            [lint]
            duplicateKeys = false
            emptyValues = false

            """
        let toml: Toml = try! Toml(withString: tomlContents)
        let configuration: Configuration = try! Configuration.make(toml: toml)

        XCTAssertEqual(configuration.tomlContents(), tomlContents)
    }
}
