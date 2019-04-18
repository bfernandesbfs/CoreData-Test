//
//  ViewController.swift
//  CoreData Test
//
//  Created by Bruno Fernandes on 17/04/19.
//  Copyright © 2019 bfs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var list: [Product] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private let service: ProductService = ProductService()

    public override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    // MARK: - Action Button

    @IBAction func pressed(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Add", message: "New product", preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }

            let product = Product(id: "\(self.list.count)", name: nameToSave)
            self.service.set(product: product, completion: { isSuccess in
                if isSuccess {
                    self.list.append(product)
                } else {
                    print("Ops")
                }
            })

        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addTextField()

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    // MARK: Private Methods

    private func loadData() {
        
        service.list { (result) in
            switch result {
            case .success(let value):
                self.list = value
            case .failure(let error):
                print(error)
            }
        }
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        let product = list[indexPath.row]

        if editingStyle == .delete {

            self.service.remove(product: product) { isSuccess in
                if isSuccess {
                    DispatchQueue.main.async {
                        self.list.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
}
