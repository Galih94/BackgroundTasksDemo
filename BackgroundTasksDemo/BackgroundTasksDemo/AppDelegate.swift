//
//  AppDelegate.swift
//  BackgroundTasksDemo
//
//  Created by Galih Samudra on 14/08/25.
//
import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1. Register BGTask IDs
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.example.demo.refresh",
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.example.demo.processing",
            using: nil
        ) { task in
            self.handleProcessingTask(task: task as! BGProcessingTask)
        }

        // 2. Background fetch
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        return true
    }

    // MARK: Background Fetch
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("🔄 Background Fetch triggered")
        // Simulate fetch work
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            print("✅ Background Fetch done")
            completionHandler(.newData)
        }
    }

    // MARK: BGTaskScheduler
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh() // Schedule next
        print("🔄 BGAppRefreshTask triggered")

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operation = BlockOperation {
            print("✅ BGAppRefreshTask finished")
        }

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        queue.addOperation(operation)
    }

    private func handleProcessingTask(task: BGProcessingTask) {
        print("🔄 BGProcessingTask triggered (long-running work)")

        task.expirationHandler = {
            print("⚠️ BGProcessingTask expired")
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            print("✅ BGProcessingTask finished")
            task.setTaskCompleted(success: true)
        }
    }

    // MARK: Scheduling
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.example.demo.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15) // 15 sec later
        do {
            try BGTaskScheduler.shared.submit(request)
            print("📅 BGAppRefreshTask scheduled")
        } catch {
            print("❌ Failed to schedule app refresh: \(error)")
        }
    }

    func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: "com.example.demo.processing")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        do {
            try BGTaskScheduler.shared.submit(request)
            print("📅 BGProcessingTask scheduled")
        } catch {
            print("❌ Failed to schedule processing task: \(error)")
        }
    }
}
