//
//  PlusAndDisclosureDelegate.swift
//  PortalNavigation
//
//  Created by John Gallaugher on 4/21/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation

protocol PlusAndDisclosureDelegate: class {
    func didTapPlusButton(at indexPath: IndexPath)
    func didTapDisclosure(at indexPath: IndexPath)
}
