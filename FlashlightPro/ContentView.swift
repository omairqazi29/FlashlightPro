import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isOn = false
    @State private var brightness: Double = 1.0
    @State private var isSOS = false
    @State private var sosTimer: Timer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 50) {
                Spacer()

                Image(systemName: isOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .font(.system(size: 100))
                    .foregroundColor(isOn ? .yellow : .gray)

                Text(isOn ? "ON" : "OFF")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                Button(action: toggleFlashlight) {
                    Circle()
                        .fill(isOn ? Color.yellow : Color.gray.opacity(0.5))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "power")
                                .font(.system(size: 50))
                                .foregroundColor(isOn ? .black : .white)
                        )
                }

                if isOn {
                    VStack(spacing: 15) {
                        Text("Brightness")
                            .foregroundColor(.white)
                            .font(.headline)

                        Slider(value: $brightness, in: 0.1...1.0)
                            .tint(.yellow)
                            .padding(.horizontal, 40)
                            .onChange(of: brightness) { _ in
                                adjustBrightness()
                            }
                    }
                }

                Button(action: toggleSOS) {
                    Text(isSOS ? "Stop SOS" : "SOS Mode")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(isSOS ? Color.red : Color.orange)
                        .cornerRadius(15)
                }

                Spacer()
            }
        }
    }

    func toggleFlashlight() {
        isOn.toggle()
        if isSOS {
            isSOS = false
            sosTimer?.invalidate()
        }

        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if isOn {
                try device.setTorchModeOn(level: Float(brightness))
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch error")
        }
    }

    func adjustBrightness() {
        guard isOn, let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: Float(brightness))
            device.unlockForConfiguration()
        } catch {
            print("Brightness error")
        }
    }

    func toggleSOS() {
        isSOS.toggle()

        if isSOS {
            sosTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                isOn.toggle()
                toggleFlashlight()
            }
        } else {
            sosTimer?.invalidate()
            if isOn {
                toggleFlashlight()
            }
        }
    }
}

#Preview {
    ContentView()
}
