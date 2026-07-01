import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let workoutSessionManager = makeElandWorkoutSessionManager()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    registerWorkoutRuntimeChannel()

    return result
  }

  private func registerWorkoutRuntimeChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let workoutRuntimeChannel = FlutterMethodChannel(
      name: "eland_athletic/workout_runtime",
      binaryMessenger: controller.binaryMessenger
    )

    workoutRuntimeChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(
          FlutterError(
            code: "UNAVAILABLE",
            message: "Workout runtime manager is not available.",
            details: nil
          )
        )
        return
      }

      switch call.method {
      case "initialize":
        self.workoutSessionManager.initialize { success, errorMessage in
          DispatchQueue.main.async {
            if success {
              result(true)
            } else {
              result(
                FlutterError(
                  code: "HEALTHKIT_AUTH_FAILED",
                  message: errorMessage ?? "HealthKit authorization failed.",
                  details: nil
                )
              )
            }
          }
        }

      case "start":
        let args = call.arguments as? [String: Any]
        let workoutTitle = args?["workoutTitle"] as? String

        do {
          try self.workoutSessionManager.start(workoutTitle: workoutTitle)
          result(true)
        } catch {
          result(
            FlutterError(
              code: "WORKOUT_START_FAILED",
              message: error.localizedDescription,
              details: nil
            )
          )
        }

      case "update":
        result(true)

      case "pause":
        self.workoutSessionManager.pause()
        result(true)

      case "resume":
        self.workoutSessionManager.resume()
        result(true)

      case "skipPhase":
        result(true)

      case "stop":
        self.workoutSessionManager.stop()
        result(true)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
