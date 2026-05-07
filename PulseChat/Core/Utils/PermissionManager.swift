import Foundation
import AVFoundation
import Photos
import CoreLocation

@MainActor
final class PermissionManager: NSObject, CLLocationManagerDelegate {

    static let shared = PermissionManager()

    private let locationManager = CLLocationManager()

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestAllPermissions() async {
        requestLocationPermission()
        requestCameraPermission()
        requestPhotoLibraryPermission()
        await NotificationManager.shared.requestAuthorization()
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
    }

    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }
    }
}
