import SwiftUI
import Charts

struct AccelerometerTestView: View {
    @ObservedObject var test: AccelerometerTest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.red.opacity(0.1),
                    Color.orange.opacity(0.05)
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
                                        colors: [Color.red.opacity(0.2), Color.orange.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.red, .orange],
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
                        // Data visualization card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.xyaxis.line")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                                Text("Real-time Data")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(spacing: 14) {
                                AccelDataRow(axis: "X-Axis", value: test.x, color: .red)
                                Divider()
                                AccelDataRow(axis: "Y-Axis", value: test.y, color: .green)
                                Divider()
                                AccelDataRow(axis: "Z-Axis", value: test.z, color: .blue)
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
                                    Text("Accelerometer Works")
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
                                    Text("Accelerometer Doesn't Work")
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
}

struct AccelDataRow: View {
    let axis: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(axis)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 60, alignment: .leading)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
                    .frame(height: 24)
                
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.7))
                        .frame(width: min(abs(value) / 2.0 * geometry.size.width, geometry.size.width), height: 24)
                }
                .frame(height: 24)
            }
            
            Text(String(format: "%.2f", value))
                .font(.system(size: 16, weight: .semibold))
                .monospacedDigit()
                .frame(width: 70, alignment: .trailing)
        }
    }
}

struct GyroscopeTestView: View {
    @ObservedObject var test: GyroscopeTest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.green.opacity(0.1),
                    Color.teal.opacity(0.05)
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
                                        colors: [Color.green.opacity(0.2), Color.teal.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "gyroscope")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .teal],
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
                        // 3D rotation visualization
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "rotate.3d")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                Text("Rotation Angles")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            HStack(spacing: 16) {
                                RotationCard(label: "Pitch", value: test.pitch, color: .red)
                                RotationCard(label: "Roll", value: test.roll, color: .green)
                                RotationCard(label: "Yaw", value: test.yaw, color: .blue)
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
                                    Text("Gyroscope Works")
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
                                    Text("Gyroscope Doesn't Work")
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
}

struct RotationCard: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(Color(.systemGray6), lineWidth: 4)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: abs(value) / 360.0)
                    .stroke(color, lineWidth: 4)
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                
                Text(String(format: "%.0f°", value))
                    .font(.system(size: 15, weight: .bold))
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MagnetometerTestView: View {
    @ObservedObject var test: MagnetometerTest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.1),
                    Color.blue.opacity(0.05)
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
                                        colors: [Color.indigo.opacity(0.2), Color.blue.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "location.north.fill")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.indigo, .blue],
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
                        // Compass visualization
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "safari")
                                    .font(.system(size: 20))
                                    .foregroundColor(.indigo)
                                Text("Compass Reading")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(spacing: 24) {
                                ZStack {
                                    // Background rings
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.indigo.opacity(0.05), Color.blue.opacity(0.02)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 200, height: 200)
                                    
                                    Circle()
                                        .stroke(Color(.systemGray6), lineWidth: 2)
                                        .frame(width: 160, height: 160)
                                    
                                    // Cardinal directions with modern styling
                                    VStack {
                                        Text("N")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.red, .red.opacity(0.8)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                        Spacer()
                                    }
                                    .frame(height: 180)
                                    
                                    HStack {
                                        Text("W")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("E")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: 180)
                                    
                                    VStack {
                                        Spacer()
                                        Text("S")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(height: 180)
                                    
                                    // Modern compass needle
                                    GeometryReader { geometry in
                                        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                        
                                        ZStack {
                                            // North arrow with gradient
                                            Path { path in
                                                path.move(to: CGPoint(x: center.x, y: center.y - 65))
                                                path.addLine(to: CGPoint(x: center.x - 8, y: center.y - 35))
                                                path.addLine(to: CGPoint(x: center.x + 8, y: center.y - 35))
                                                path.closeSubpath()
                                            }
                                            .fill(
                                                LinearGradient(
                                                    colors: [.red, .red.opacity(0.7)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                                            
                                            // South pointer
                                            Path { path in
                                                path.move(to: CGPoint(x: center.x, y: center.y + 65))
                                                path.addLine(to: CGPoint(x: center.x - 6, y: center.y + 35))
                                                path.addLine(to: CGPoint(x: center.x + 6, y: center.y + 35))
                                                path.closeSubpath()
                                            }
                                            .fill(Color.gray.opacity(0.6))
                                        }
                                        .rotationEffect(.degrees(test.heading > 0 ? -(360 - test.heading) : 0), anchor: UnitPoint(x: 0.5, y: 0.5))
                                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: test.heading)
                                    }
                                    .frame(width: 200, height: 200)
                                    
                                    // Center indicator
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 20, height: 20)
                                            .shadow(color: .black.opacity(0.1), radius: 2)
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.indigo, .blue],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 12, height: 12)
                                    }
                                }
                                .frame(height: 220)
                                
                                // Heading display
                                Text(headingDirection(test.heading))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
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
                                    Text("Compass Works")
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
                                    Text("Compass Doesn't Work")
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
    
    private func headingDirection(_ heading: Double) -> String {
        // Invert the heading since the sensor reports opposite values
        let invertedHeading = heading > 0 ? 360 - heading : 0
        
        switch invertedHeading {
        case 337.5..<360, 0..<22.5: return "North"
        case 22.5..<67.5: return "Northwest"
        case 67.5..<112.5: return "West"
        case 112.5..<157.5: return "Southewest"
        case 157.5..<202.5: return "South"
        case 202.5..<247.5: return "Southeast"
        case 247.5..<292.5: return "East"
        case 292.5..<337.5: return "Northeast"
        default: return "Unknown"
        }
    }
}

struct ProximityTestView: View {
    @ObservedObject var test: ProximityTest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.1),
                    Color.yellow.opacity(0.05)
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
                                        colors: [Color.orange.opacity(0.2), Color.yellow.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "sensor")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
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
                        // Sensor visualization
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "wave.3.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                                Text("Sensor Status")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(spacing: 24) {
                                // Status display
                                Text(test.isNear ? "Object Detected" : "Clear")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(test.isNear ? .red : .green)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
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
                                    Text("Proximity Sensor Works")
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
                                    Text("Proximity Sensor Doesn't Work")
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
}

struct AmbientLightTestView: View {
    @ObservedObject var test: AmbientLightTest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.yellow.opacity(0.1),
                    Color.orange.opacity(0.05)
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
                                        colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "light.max")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
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
                        // Light visualization
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                                Text("Brightness Level")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(spacing: 24) {
                                // Brightness display
                                Text("\(Int(test.brightnessLevel * 100))%")
                                    .font(.system(size: 48, weight: .bold))
                                    .monospacedDigit()
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
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
                                    Text("Ambient Light Works")
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
                                    Text("Ambient Light Doesn't Work")
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
    
    private func brightnessDescription(_ level: Float) -> String {
        switch level {
        case 0..<0.2: return "Very Dark"
        case 0.2..<0.4: return "Dark"
        case 0.4..<0.6: return "Medium"
        case 0.6..<0.8: return "Bright"
        default: return "Very Bright"
        }
    }
}
