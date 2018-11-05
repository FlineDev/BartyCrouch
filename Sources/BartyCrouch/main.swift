//  Created by Cihat Gündüz on 10.02.16.

import Foundation

func run() {
    CommandLineParser().parse { commonOptions, subCommandOptions in
        CommandLineActor().act(commonOptions: commonOptions, subCommandOptions: subCommandOptions)
    }
}

run()
