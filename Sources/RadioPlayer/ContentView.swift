import SwiftUI

struct ContentView: View {
    @ObservedObject var player: RadioPlayer

    var body: some View {
        VStack(spacing: 12) {
            Text("Kan 88")
                .font(.headline)

            Text("Israeli Public Radio")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: { player.togglePlayPause() }) {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)

            statusView

            HStack(spacing: 6) {
                Image(systemName: "speaker.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Slider(value: $player.volume, in: 0...1)
                    .frame(width: 120)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(width: 200)
    }

    @ViewBuilder
    private var statusView: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            Text(player.status.rawValue)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private var statusColor: Color {
        switch player.status {
        case .playing: return .green
        case .connecting, .buffering: return .orange
        case .error: return .red
        case .stopped: return .gray
        }
    }
}
