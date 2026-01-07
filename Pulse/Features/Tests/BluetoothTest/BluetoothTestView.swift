import SwiftUI
import CoreBluetooth

struct BluetoothTestView: View {
    @ObservedObject var test: BluetoothTest
    @Environment(\.dismiss) var dismiss
    
    var bluetoothStateColor: Color {
        switch test.bluetoothState {
        case .poweredOn:
            return .green
        case .poweredOff:
            return .red
        case .unsupported:
            return .red
        case .unauthorized:
            return .red
        default:
            return .orange
        }
    }
    
    var displayedDevices: [BluetoothDevice] {
        Array(test.discoveredDevices.prefix(3))
    }
    
    var body: some View {
        ZStack {
            // Gradient background
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
                VStack(spacing: 0) {
                    // Header with icon
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 40)
                        
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 8) {
                            Text(test.title)
                                .font(.system(size: 32, weight: .bold))
                            
                            Text(test.description)
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    VStack(spacing: 20) {
                        // Bluetooth state card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "bluetooth")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                Text("Bluetooth State")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            HStack {
                                Text("Status:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(bluetoothStateColor)
                                        .frame(width: 8, height: 8)
                                    Text(test.bluetoothStateText(test.bluetoothState))
                                        .fontWeight(.semibold)
                                        .foregroundColor(bluetoothStateColor)
                                }
                            }
                            
                            if test.bluetoothState == .poweredOff {
                                Divider()
                                HStack(spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 16))
                                    Text("Please turn on Bluetooth in Settings")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if test.bluetoothState == .unsupported {
                                Divider()
                                HStack(spacing: 10) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                    Text("Bluetooth is not supported on this device")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                        
                        // Devices found card
                        if test.bluetoothState == .poweredOn {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "wave.3.right")
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                    Text("Nearby Devices")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    if test.isScanning {
                                        ProgressView()
                                            .scaleEffect(0.9)
                                    }
                                }
                                
                                HStack {
                                    Text("Found:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(test.discoveredDevices.count)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                                
                                if !displayedDevices.isEmpty {
                                    Divider()
                                    
                                    VStack(alignment: .leading, spacing: 14) {
                                        ForEach(displayedDevices) { device in
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.blue.opacity(0.15))
                                                        .frame(width: 36, height: 36)
                                                    
                                                    Image(systemName: "circle.fill")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(.blue)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(device.displayName)
                                                        .font(.system(size: 15, weight: .medium))
                                                    
                                                    Text("Signal: \(device.rssi) dBm")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                Spacer()
                                            }
                                        }
                                        
                                        if test.discoveredDevices.count > 3 {
                                            Text("+ \(test.discoveredDevices.count - 3) more device(s)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.top, 4)
                                        }
                                    }
                                } else if test.isScanning {
                                    HStack {
                                        Spacer()
                                        VStack(spacing: 10) {
                                            ProgressView()
                                            Text("Scanning for devices...")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 20)
                                } else {
                                    Text("No devices found")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                }
                            }
                            .padding(24)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                Text("How to Test")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                InstructionRow(number: "1", text: "Ensure Bluetooth is turned on")
                                InstructionRow(number: "2", text: "Wait for nearby devices to appear")
                                InstructionRow(number: "3", text: "Verify the device count increases")
                                InstructionRow(number: "4", text: "Mark the test result below")
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        if test.bluetoothState == .poweredOn {
                            Button(action: {
                                test.confirmSuccess()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Bluetooth Works")
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
                                    Text("Bluetooth Doesn't Work")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
                            }
                        } else if test.bluetoothState == .poweredOff {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                
                                Text("Bluetooth is turned off")
                                    .font(.headline)
                                
                                Text("Please turn on Bluetooth in Settings to run this test")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 20)
                        } else if test.bluetoothState == .unsupported {
                            VStack(spacing: 12) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                                
                                Text("Bluetooth is not supported")
                                    .font(.headline)
                                
                                Text("This device does not support Bluetooth")
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
            test.stopScanning()
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}
