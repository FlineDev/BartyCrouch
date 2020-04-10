import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        NSLocalizedString("Love", comment: "Comment for Love")
        NSLocalizedString("How are you?", comment: "")
        NSLocalizedString("I'm fine", comment: "Comment for I'm fine - #bc-ignore!")

        title = BartyCrouch.translate(key: "onboarding.first-page.header-title", translations: [.english: "Page Title", .german: "Seitentitel"])
        let lines: Int = (0 ..< 10).map { "\($0 + 1): \(BartyCrouch.translate(key: "onboarding.first-page.line", translations: [:], comment: "Line Comment"))" }.count

        BartyCrouch
            .translate(
                key : "ShortKey",
                translations : [
                    BartyCrouch.SupportedLanguage.english :
                    "Some Translation"
                ]
        )
    }
}
