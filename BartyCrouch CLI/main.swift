//
//  main.swift
//  BartyCrouch CLI
//
//  Created by Cihat Gündüz on 10.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation
import BartyCrouchKit

func run() {
    CommandLineParser().parse { commonOptions, subCommandOptions in
        CommandLineActor().act(commonOptions: commonOptions, subCommandOptions: subCommandOptions)
    }
}

run()
