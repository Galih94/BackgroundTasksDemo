//
//  ViewController.swift
//  BackgroundTasksDemo
//
//  Created by Galih Samudra on 14/08/25.
//

import UIKit

class ViewController: UIViewController {

    private var bgTaskID: UIBackgroundTaskIdentifier = .invalid

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        let btn1 = makeButton(title: "Schedule BGAppRefresh") {
            (UIApplication.shared.delegate as? AppDelegate)?.scheduleAppRefresh()
        }

        let btn2 = makeButton(title: "Schedule BGProcessing") {
            (UIApplication.shared.delegate as? AppDelegate)?.scheduleProcessingTask()
        }

        let btn3 = makeButton(title: "Start Short-lived Task") {
            self.startShortLivedTask()
        }

        stack.addArrangedSubview(btn1)
        stack.addArrangedSubview(btn2)
        stack.addArrangedSubview(btn3)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func makeButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    // Short-lived background task example
    private func startShortLivedTask() {
        bgTaskID = UIApplication.shared.beginBackgroundTask(withName: "ShortTask") {
            print("⚠️ Short task expired")
            UIApplication.shared.endBackgroundTask(self.bgTaskID)
            self.bgTaskID = .invalid
        }

        print("🔄 Short task started")

        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            print("✅ Short task completed")
            UIApplication.shared.endBackgroundTask(self.bgTaskID)
            self.bgTaskID = .invalid
        }
    }
}
