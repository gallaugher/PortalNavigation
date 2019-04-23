//
//  ViewController.swift
//  PortalNavigation
//
//  Created by John Gallaugher on 4/21/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Element {
        var name: String
        var id: String
        var type: String
        var parentID: String
        var hierarchyLevel: Int // level indented, 0 for home, 1 for first buttons + pages, etc...
        var chidrenIDs: [String]
    }
    
    var originalElements: [Element] = []
    var elements: [Element] = []
    let indentBase = 26 // previously 41
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        originalElements = [Element(name: "Home", id: "Home", type: "Home", parentID: "", hierarchyLevel: 0, chidrenIDs: [])]
        
        sortArrayRowsIntoHierarchy()
        tableView.reloadData()
    }
    
    func sortArrayRowsIntoHierarchy() {
        let homeIndex = originalElements.firstIndex(where: {$0.parentID == ""})
        if let homeIndex = homeIndex {
            elements.append(originalElements[homeIndex])
            originalElements.remove(at: homeIndex)
        }
        
        var indexToSearch = 0
        repeat{
            // Find all children
            for index in 0..<elements[indexToSearch].chidrenIDs.count {
                let childID = elements[indexToSearch].chidrenIDs[index]
                let foundIndex = originalElements.firstIndex(where: {$0.id == childID})
                if let foundIndex = foundIndex {
                    originalElements[foundIndex].hierarchyLevel = elements[indexToSearch].hierarchyLevel+1
                    elements.insert(originalElements[foundIndex], at: indexToSearch+1+index)
                }
            }
            indexToSearch = indexToSearch + 1
        } while indexToSearch < elements.count
    }
}

extension ViewController: PlusAndDisclosureDelegate {
    func addAButtonAndPage(buttonName: String, indexPath: IndexPath) {
        let newButtonID = UUID().uuidString
        let newPageID = UUID().uuidString
        let newButton = Element(name: buttonName, id: newButtonID, type: "Button", parentID: elements[indexPath.row].id, hierarchyLevel: elements[indexPath.row].hierarchyLevel+1, chidrenIDs: [newPageID])
        let newPage = Element(name: buttonName, id: newPageID, type: "Page", parentID: newButtonID, hierarchyLevel: elements[indexPath.row].hierarchyLevel+2, chidrenIDs: [])
        
        elements[indexPath.row].chidrenIDs.append(newButtonID)
        elements.append(newButton)
        elements.append(newPage)
        originalElements = elements
        elements = []
        sortArrayRowsIntoHierarchy()
        tableView.reloadData()
    }
    
    func addPage(indexPath: IndexPath) {
        let newPageID = UUID().uuidString
        let newPage = Element(name: elements[indexPath.row].name, id: newPageID, type: "Page", parentID: elements[indexPath.row].id, hierarchyLevel: elements[indexPath.row].hierarchyLevel+1, chidrenIDs: [])
        elements[indexPath.row].chidrenIDs.append(newPageID)
        elements.append(newPage)
        originalElements = elements
        elements = []
        sortArrayRowsIntoHierarchy()
        tableView.reloadData()
    }
    
    func didTapPlusButton(at indexPath: IndexPath) {
        switch elements[indexPath.row].type {
        case "Page", "Home":
            showInputDialog(title: nil,
                            message: "Open new page with a button named:",
                            actionTitle: "Create Button",
                            cancelTitle: "Cancel",
                            inputPlaceholder: nil,
                            inputKeyboardType: .default,
                            actionHandler: {(input:String?) in
                                guard let screenName = input else {
                                    return
                                }
                                self.addAButtonAndPage(buttonName: screenName, indexPath: indexPath)},
                            cancelHandler: nil)
        case "Button":
            showTwoButtonAlert(title: nil,
                               message: "Create a new page from button \(elements[indexPath.row].name):",
                actionTitle: "Create Page",
                cancelTitle: "Cancel",
                actionHandler: {_ in self.addPage(indexPath: indexPath)},
                cancelHandler: nil)
        default:
            print("ERROR in default case of didTapPlusButton")
        }
    }
    
    func didTapDisclosure(at indexPath: IndexPath) {
        print("*** You Tapped the Disclosure Button at \(indexPath.row)")
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row].type {
        case "Home":
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
            cell.delegate = self
            cell.indexPath = indexPath
            //cell.childrenLabel.text = "\(elements[indexPath.row].chidrenIDs)"
            return cell
        case "Button":
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonTableViewCell
            cell.delegate = self
            cell.indexPath = indexPath
            var newRect = cell.indentView.frame
            // now change x value & reassign to indentview
            let indentAmount = CGFloat(elements[indexPath.row].hierarchyLevel*indentBase)
            newRect = CGRect(x: indentAmount, y: newRect.origin.y, width: newRect.width, height: newRect.height)
            UIView.animate(withDuration: 0.5, animations: {cell.indentView.frame = newRect})
            print("*** Button \(elements[indexPath.row].name) has a hierarchy level \(elements[indexPath.row].hierarchyLevel)")
            print(">>> indenting button view \(indentAmount)")
            cell.button.setTitle(elements[indexPath.row].name, for: .normal)
            // cell.childrenLabel.text = "\(elements[indexPath.row].chidrenIDs)"
            return cell
        case "Page":
            let cell = tableView.dequeueReusableCell(withIdentifier: "PageCell", for: indexPath) as! PageTableViewCell
           // cell.pageName.text = elements[indexPath.row].name
            cell.delegate = self
            cell.indexPath = indexPath
            var newRect = cell.indentView.frame
            // now change x value & reassign to indentview
            let indentAmount = CGFloat(elements[indexPath.row].hierarchyLevel*indentBase)
            newRect = CGRect(x: indentAmount, y: newRect.origin.y, width: newRect.width, height: newRect.height)
            UIView.animate(withDuration: 0.5, animations: {cell.indentView.frame = newRect})
            print("PPP Page \(elements[indexPath.row].name) has a hierarchy level \(elements[indexPath.row].hierarchyLevel)")
            print(">>> indenting page view \(indentAmount)")
            // cell.childrenLabel.text = "\(elements[indexPath.row].chidrenIDs)"
            // if parent has multiple children then <> icons, else return icon
            let parentIndex = elements.firstIndex(where: {$0.id == elements[indexPath.row].parentID})
            if let parentIndex = parentIndex {
                if elements[parentIndex].chidrenIDs.count > 1 {
                    cell.pageIcon.image = UIImage(named:  "pageGroup")
                } else {
                    cell.pageIcon.image = UIImage(named:  "singlePage")
                }
            }
            return cell
        default:
            print("*** ERROR: cellForRowAt had incorrect case.")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(">> Selected row at indexPath.row: \(indexPath.row), with hierarchy \(elements[indexPath.row].hierarchyLevel) <<")
    }
}
