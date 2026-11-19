import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private let workoutSessionManager = makeElandWorkoutSessionManager()

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(
      scene,
      willConnectTo: session,
      options: connectionOptions
    )

    DispatchQueue.main.async { [weak self] in
      self?.registerWorkoutRuntimeChannel()
    }
  }

  private func registerWorkoutRuntimeChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "eland_athletic/workout_runtime",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(
          code: "UNAVAILABLE",
          message: "Workout runtime manager is not available.",
          details: nil
        ))
        return
      }

      switch call.method {
      case "initialize":
        self.workoutSessionManager.initialize { success, errorMessage in
          DispatchQueue.main.async {
            if success {
              result(true)
            } else {
              result(FlutterError(
                code: "HEALTHKIT_AUTH_FAILED",
                message: errorMessage ?? "HealthKit authorization failed.",
                details: nil
              ))
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
          result(FlutterError(
            code: "WORKOUT_START_FAILED",
            message: error.localizedDescription,
            details: nil
          ))
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
}
