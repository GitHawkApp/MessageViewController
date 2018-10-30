//
//  ViewController.swift
//  Examples
//
//  Created by Ryan Nystrom on 1/28/18.
//  Copyright © 2018 Ryan Nystrom. All rights reserved.
//

import UIKit
import MessageViewController

class ViewController: MessageViewController, UITableViewDataSource, UITableViewDelegate, MessageAutocompleteControllerDelegate {

    var data = "Lorem ipsum dolor sit amet|consectetur adipiscing elit|sed do eiusmod|tempor incididunt|ut labore et dolore|magna aliqua| Ut enim ad minim|veniam, quis nostrud|exercitation ullamco|laboris nisi ut aliquip|ex ea commodo consequat|Duis aute|irure dolor in reprehenderit|in voluptate|velit esse cillum|dolore eu|fugiat nulla pariatur|Excepteur sint occaecat|cupidatat non proident|sunt in culpa|qui officia|deserunt|mollit anim id est laborum"
        .components(separatedBy: "|")
    let users = ["rnystrom", "BasThomas", "jessesquires", "Sherlouk", "omwomw"]
    var autocompleteUsers = [String]()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        borderColor = .lightGray

        messageView.textViewInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 16)
        messageView.font = UIFont.systemFont(ofSize: 18)

        messageView.setButton(title: "Add", for: .normal, position: .left)
        messageView.addButton(target: self, action: #selector(onLeftButton), position: .left)
        messageView.leftButtonTint = .blue
        messageView.showLeftButton = true

        messageView.setButton(inset: 10, position: .left)
        messageView.setButton(inset: 15, position: .right)

        messageView.textView.placeholderText = "New message..."
        messageView.textView.placeholderTextColor = .lightGray

        messageView.setButton(title: "Send", for: .normal, position: .right)
        messageView.addButton(target: self, action: #selector(onRightButton), position: .right)
        messageView.rightButtonTint = .blue

        messageAutocompleteController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        messageAutocompleteController.tableView.dataSource = self
        messageAutocompleteController.tableView.delegate = self
        messageAutocompleteController.register(prefix: "@")
        
        // Set custom attributes for an autocompleted string
        let tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        messageAutocompleteController.registerAutocomplete(prefix: "@", attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: tintColor,
            .backgroundColor: tintColor.withAlphaComponent(0.1)
            ])
        
        messageAutocompleteController.delegate = self

        setup(scrollView: tableView)
    }

    @objc func onLeftButton() {
        print("Did press left button")
    }

    @objc func onRightButton() {
        data.append(messageView.text)
        messageView.text = ""
        tableView.reloadData()
        tableView.scrollToRow(
            at: IndexPath(row: data.count - 1, section: 0),
            at: .bottom,
            animated: true
        )
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === self.tableView
            ? data.count
            : autocompleteUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if tableView === self.tableView {
            cell.textLabel?.text = data[indexPath.row]
        } else {
            cell.textLabel?.text = autocompleteUsers[indexPath.row]
        }
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView === messageAutocompleteController.tableView {
            messageAutocompleteController.accept(autocomplete: autocompleteUsers[indexPath.row])
        }
    }

    // MARK: MessageAutocompleteControllerDelegate

    func didFind(controller: MessageAutocompleteController, prefix: String, word: String) {
        autocompleteUsers = users.filter { word.isEmpty || $0.lowercased().contains(word.lowercased()) }
        controller.show(true)
    }

}

