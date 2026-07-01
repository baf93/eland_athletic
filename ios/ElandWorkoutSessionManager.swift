import Foundation
import HealthKit

protocol ElandWorkoutSessionManaging {
    func initialize(completion: @escaping (Bool, String?) -> Void)
    func start(workoutTitle: String?) throws
    func pause()
    func resume()
    func stop()
}

func makeElandWorkoutSessionManager() -> ElandWorkoutSessionManaging {
    if #available(iOS 26.0, *) {
        return ElandWorkoutSessionManager()
    }

    return ElandWorkoutSessionUnavailableManager()
}

final class ElandWorkoutSessionUnavailableManager: ElandWorkoutSessionManaging {
    func initialize(completion: @escaping (Bool, String?) -> Void) {
        completion(true, nil)
    }

    func start(workoutTitle: String?) throws {}
    func pause() {}
    func resume() {}
    func stop() {}
}

@available(iOS 26.0, *)
final class ElandWorkoutSessionManager: NSObject,
    ElandWorkoutSessionManaging,
    HKWorkoutSessionDelegate,
    HKLiveWorkoutBuilderDelegate {

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func initialize(completion: @escaping (Bool, String?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, "HealthKit is not available on this device.")
            return
        }

        let workoutType = HKObjectType.workoutType()

        healthStore.requestAuthorization(
            toShare: [workoutType],
            read: [workoutType]
        ) { success, error in
            completion(success, error?.localizedDescription)
        }
    }

    func start(workoutTitle: String?) throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .functionalStrengthTraining
        configuration.locationType = .indoor

        let session = try HKWorkoutSession(
            healthStore: healthStore,
            configuration: configuration
        )

        let builder = session.associatedWorkoutBuilder()

        session.delegate = self
        builder.delegate = self
        builder.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )

        self.session = session
        self.builder = builder

        let startDate = Date()

        session.prepare()
        session.startActivity(with: startDate)

        builder.beginCollection(withStart: startDate) { _, _ in }
    }

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }

    func stop() {
        let endDate = Date()

        session?.stopActivity(with: endDate)

        builder?.endCollection(withEnd: endDate) { [weak self] _, _ in
            self?.builder?.finishWorkout { _, _ in
                self?.session?.end()
                self?.session = nil
                self?.builder = nil
            }
        }
    }

    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {}

    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {}

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {}
}
