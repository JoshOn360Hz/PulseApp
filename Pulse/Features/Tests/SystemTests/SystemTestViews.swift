import SwiftUI
import Network

struct BatteryTestView: View {
    @ObservedObject var test: BatteryTest
    @Environment(\.dismiss) var dismiss
    
    var batteryColor: Color {
        if test.level < 0.2 { return .red }
        if test.level < 0.5 { return .orange }
        return .green
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    batteryColor.opacity(0.1),
                    batteryColor.opacity(0.05)
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
                                        colors: [batteryColor.opacity(0.2), batteryColor.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "battery.100")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [batteryColor, batteryColor.opacity(0.8)],
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
                        // Battery visualization card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(batteryColor)
                                Text("Battery Status")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(spacing: 20) {
                                HStack(spacing: 8) {
                                    Image(systemName: batteryStateIcon(test.state))
                                        .foregroundColor(.secondary)
                                    Text(test.batteryStateString(test.state))
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                        
                        // Battery info card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(batteryColor)
                                Text("Battery Information")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Status")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(test.batteryStateString(test.state))
                                        .fontWeight(.medium)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Level")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(batteryColor)
                                            .frame(width: 8, height: 8)
                                        Text(String(format: "%.0f%%", test.level * 100))
                                            .fontWeight(.semibold)
                                            .foregroundColor(batteryColor)
                                    }
                                }
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
                    if test.isMonitoring && test.status == .running {
                        VStack(spacing: 16) {
                            Button(action: {
                                test.confirmSuccess()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Battery Works")
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
                                    Text("Battery Doesn't Work")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
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
            test.stopMonitoring()
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
    
    private var batteryIcon: some View {
        ZStack(alignment: .leading) {
            // Battery outline
            RoundedRectangle(cornerRadius: 12)
                .stroke(batteryColor, lineWidth: 4)
                .frame(width: 160, height: 80)
            
            // Battery fill
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [batteryColor, batteryColor.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(10, 150 * CGFloat(test.level)), height: 70)
                .padding(.leading, 5)
            
            // Battery terminal
            RoundedRectangle(cornerRadius: 3)
                .fill(batteryColor)
                .frame(width: 8, height: 35)
                .offset(x: 164)
        }
        .frame(width: 172, height: 80)
    }
    
    private func batteryStateIcon(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .unknown: return "battery.0"
        case .unplugged: return "battery.50"
        case .charging: return "battery.100.bolt"
        case .full: return "battery.100"
        @unknown default: return "battery.0"
        }
    }
}

struct NetworkTestView: View {
    @ObservedObject var test: NetworkTest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    test.isConnected ? Color.green.opacity(0.1) : Color.red.opacity(0.1),
                    test.isConnected ? Color.blue.opacity(0.05) : Color.orange.opacity(0.05)
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
                                        colors: [
                                            test.isConnected ? Color.green.opacity(0.2) : Color.red.opacity(0.2),
                                            test.isConnected ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: test.isConnected ? "wifi" : "wifi.slash")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: test.isConnected ? [.green, .blue] : [.red, .orange],
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
                        // Connection status card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "network")
                                    .font(.system(size: 20))
                                    .foregroundColor(test.isConnected ? .green : .red)
                                Text("Connection Status")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(spacing: 16) {
                                if let type = test.connectionType {
                                    HStack(spacing: 8) {
                                        Image(systemName: connectionTypeIcon(type))
                                            .foregroundColor(.blue)
                                        Text(type.description)
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                } else {
                                    Text("No Connection")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                        
                        // Network information
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(test.isConnected ? .green : .red)
                                Text("Network Information")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Connection Type")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(test.connectionType?.description ?? "None")
                                        .fontWeight(.medium)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Status")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(test.isConnected ? Color.green : Color.red)
                                            .frame(width: 8, height: 8)
                                        Text(test.isConnected ? "Active" : "Inactive")
                                            .fontWeight(.semibold)
                                            .foregroundColor(test.isConnected ? .green : .red)
                                    }
                                }
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
                    if test.status == .running {
                        VStack(spacing: 16) {
                            Button(action: {
                                test.confirmSuccess()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Network Works")
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
                                    Text("Network Doesn't Work")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
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
            test.stopMonitoring()
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
    
    private func connectionTypeIcon(_ type: NWInterface.InterfaceType) -> String {
        switch type {
        case .wifi: return "wifi"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .wiredEthernet: return "cable.connector"
        default: return "network"
        }
    }
}

struct ThermalStateTestView: View {
    @ObservedObject var test: ThermalStateTest
    @Environment(\.dismiss) var dismiss
    
    var thermalColor: Color {
        switch test.thermalState {
        case .nominal: return .green
        case .fair: return .yellow
        case .serious: return .orange
        case .critical: return .red
        @unknown default: return .gray
        }
    }
    
    var thermalIcon: String {
        switch test.thermalState {
        case .nominal: return "thermometer.medium"
        case .fair: return "thermometer.medium"
        case .serious: return "thermometer.high"
        case .critical: return "exclamationmark.thermometer"
        @unknown default: return "thermometer"
        }
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    thermalColor.opacity(0.1),
                    thermalColor.opacity(0.05)
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
                                        colors: [thermalColor.opacity(0.2), thermalColor.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: thermalIcon)
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [thermalColor, thermalColor.opacity(0.8)],
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
                        // Thermal state card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: thermalIcon)
                                    .font(.system(size: 20))
                                    .foregroundColor(thermalColor)
                                Text("Thermal State")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            HStack {
                                Text("Status:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(thermalColor)
                                        .frame(width: 8, height: 8)
                                    Text(test.thermalStateString(test.thermalState))
                                        .fontWeight(.semibold)
                                        .foregroundColor(thermalColor)
                                }
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
                    if test.status == .running {
                        VStack(spacing: 16) {
                            Button(action: {
                                test.confirmSuccess()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Looks good")
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
                                    Text("Issue")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
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
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}
