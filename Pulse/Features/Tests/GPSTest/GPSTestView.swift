import SwiftUI
import CoreLocation

struct GPSTestView: View {
    @ObservedObject var test: GPSTest
    @Environment(\.dismiss) var dismiss
    
    var authorizationStatusText: String {
        switch test.authorizationStatus {
        case .notDetermined:
            return "Not Requested"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Authorized"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        @unknown default:
            return "Unknown"
        }
    }
    
    var authorizationStatusColor: Color {
        switch test.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return .green
        case .denied, .restricted:
            return .red
        default:
            return .orange
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.cyan.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Icon
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "location.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        
                        Text("GPS Test")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    // Authorization status card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.blue)
                            Text("Authorization Status")
                                .font(.headline)
                        }
                        
                        HStack {
                            Text("Status:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(authorizationStatusText)
                                .fontWeight(.semibold)
                                .foregroundColor(authorizationStatusColor)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    // Location data card
                    if test.authorizationStatus == .authorizedWhenInUse || test.authorizationStatus == .authorizedAlways {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Location Data")
                                    .font(.headline)
                            }
                            
                            if test.isUpdatingLocation {
                                if let location = test.currentLocation {
                                    VStack(spacing: 12) {
                                        HStack {
                                            Text("Latitude:")
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text(String(format: "%.6f°", location.coordinate.latitude))
                                                .fontWeight(.medium)
                                        }
                                        
                                        HStack {
                                            Text("Longitude:")
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text(String(format: "%.6f°", location.coordinate.longitude))
                                                .fontWeight(.medium)
                                        }
                                        
                                        HStack {
                                            Text("Accuracy:")
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            if location.horizontalAccuracy >= 0 {
                                                Text("±\(Int(location.horizontalAccuracy))m")
                                                    .fontWeight(.medium)
                                                    .foregroundColor(
                                                        location.horizontalAccuracy < 100 ? .green :
                                                        location.horizontalAccuracy < 500 ? .orange : .red
                                                    )
                                            } else {
                                                Text("Unknown")
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        if let altitude = location.altitude as Double?, location.verticalAccuracy >= 0 {
                                            HStack {
                                                Text("Altitude:")
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Text("\(Int(altitude))m")
                                                    .fontWeight(.medium)
                                            }
                                        }
                                    }
                                } else {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Searching for GPS signal...")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                }
                            } else {
                                Text("Tap 'Start Location Test' to begin")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        // Note about reduced accuracy
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("Using reduced accuracy location")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    if test.status == .running {
                        VStack(spacing: 12) {
                            if test.authorizationStatus == .authorizedWhenInUse || test.authorizationStatus == .authorizedAlways {
                                if !test.isUpdatingLocation {
                                    Button(action: {
                                        test.startLocationUpdates()
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "location.fill")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("Start Location Test")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                    }
                                }
                                
                                if test.currentLocation != nil {
                                    Button(action: {
                                        test.confirmSuccess()
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18, weight: .semibold))
                                            Text("GPS Works")
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                    }
                                    
                                    Button(action: {
                                        test.markFailed(reason: "User reported failure")
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("GPS Doesn't Work")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(16)
                                    }
                                }
                            } else if test.authorizationStatus == .denied || test.authorizationStatus == .restricted {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.orange)
                                    
                                    Text("Location access is required")
                                        .font(.headline)
                                    
                                    Text("Please enable location access in Settings to run this test")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationTitle(test.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    test.markSkipped(reason: "User skipped test")
                }) {
                    Text("Skip")
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
            }
        }
        .onAppear {
            test.reset()
            Task { try? await test.run() }
        }
        .onDisappear {
            test.stopLocationUpdates()
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}
