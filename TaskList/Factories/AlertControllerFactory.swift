//
//  AlertControllerFactory.swift
//  TaskList
//
//  Created by Perejro on 16/12/2024.
//

import Foundation
import UIKit

typealias ComplitionHandler = (String?) -> Void

enum AlertType {
    case create
    case update
}

protocol AlertControllerFactoryProtocol {
    func createAlertController(
        completion: @escaping ComplitionHandler
    ) -> UIAlertController
}

final class AlertControllerFactory: AlertControllerFactoryProtocol {
    var title: String
    var description: String?
    var value: String?
    var type: AlertType
    
    init(
        title: String,
        description: String?,
        type: AlertType,
        value: String?
    ) {
        self.title = title
        self.description = description
        self.type = type
        self.value = value
    }
    
    func createAlertController(
        completion: @escaping ComplitionHandler
    ) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        var action: UIAlertAction
        
        switch type {
        case .create:
            action = makeCreateActions(to: alertController, completion: completion)
        case .update:
            action = makeUpdateActions(to: alertController, completion: completion)
        }
        
        [action, cancelAction].forEach { alertController.addAction($0) }
        
        return alertController
    }
    
    private func makeCreateActions(to alert: UIAlertController, completion: @escaping ComplitionHandler) -> UIAlertAction {
        alert.addTextField {textField in
            textField.placeholder = "New task name"
        }
        
        let done = UIAlertAction(
            title: "Create",
            style: .default
        ) { _ in
            completion(alert.textFields?.first?.text)
        }
        
        return done
    }
    
    private func makeUpdateActions(to alert: UIAlertController, completion: @escaping ComplitionHandler) -> UIAlertAction {
        alert.addTextField { [unowned self] textField in
            textField.placeholder = "New task name"
            textField.text = value
        }
        
        let done = UIAlertAction(
            title: "Update",
            style: .default
        ) { _ in
            completion(alert.textFields?.first?.text)
        }
        
        return done
    }
    
}
