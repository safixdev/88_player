import AVFoundation
import Combine
import MediaPlayer

enum PlayerStatus: String {
    case stopped = "Stopped"
    case connecting = "Connecting..."
    case buffering = "Buffering..."
    case playing = "Playing"
    case error = "Error"
}

class RadioPlayer: ObservableObject {
    static let streamURL = URL(string: "https://kancdn.medonecdn.net/livehls/oil/kancdn-live/live/radio/kan_88/live.livx/playlist.m3u8?renditions")!

    @Published var isPlaying = false
    @Published var status: PlayerStatus = .stopped
    @Published var volume: Float = 0.5 {
        didSet { player.volume = volume }
    }

    private var player: AVPlayer
    private var cancellables = Set<AnyCancellable>()
    private var retryCount = 0
    private let maxRetries = 5

    init() {
        player = AVPlayer()
        player.volume = volume

        // Observe actual playback state
        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self, self.isPlaying else { return }
                switch status {
                case .playing:
                    self.status = .playing
                    self.retryCount = 0
                case .waitingToPlayAtSpecifiedRate:
                    self.status = .buffering
                case .paused:
                    // Player paused unexpectedly while we think we're playing
                    if self.isPlaying {
                        self.retry()
                    }
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)

        // Observe player item status for load errors
        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime)
            .sink { [weak self] _ in self?.retry() }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .AVPlayerItemNewErrorLogEntry)
            .sink { [weak self] _ in
                guard let self, self.isPlaying else { return }
                if self.player.currentItem?.status == .failed {
                    self.retry()
                }
            }
            .store(in: &cancellables)

        setupRemoteCommands()
    }

    func togglePlayPause() {
        if isPlaying {
            player.pause()
            player.replaceCurrentItem(with: nil)
            isPlaying = false
            status = .stopped
            retryCount = 0
            updateNowPlaying()
        } else {
            isPlaying = true
            status = .connecting
            loadAndPlay()
            updateNowPlaying()
        }
    }

    private func loadAndPlay() {
        let item = AVPlayerItem(url: Self.streamURL)

        // Observe this item's status
        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] itemStatus in
                guard let self, self.isPlaying else { return }
                if itemStatus == .failed {
                    self.retry()
                }
            }
            .store(in: &cancellables)

        player.replaceCurrentItem(with: item)
        player.play()
    }

    private func setupRemoteCommands() {
        // MPRemoteCommandCenter for Control Center / Now Playing widget
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self, !self.isPlaying else { return .success }
            self.togglePlayPause()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self, self.isPlaying else { return .success }
            self.togglePlayPause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

    }

    private func updateNowPlaying() {
        let center = MPNowPlayingInfoCenter.default()
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = "Kan 88"
        info[MPMediaItemPropertyArtist] = "Israeli Public Radio"
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        info[MPNowPlayingInfoPropertyIsLiveStream] = true
        center.nowPlayingInfo = info
        center.playbackState = isPlaying ? .playing : .paused
    }

    private func retry() {
        guard isPlaying else { return }
        retryCount += 1

        if retryCount > maxRetries {
            status = .error
            isPlaying = false
            player.pause()
            player.replaceCurrentItem(with: nil)
            retryCount = 0
            return
        }

        status = .connecting
        let delay = Double(min(retryCount, 4)) * 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, self.isPlaying else { return }
            self.loadAndPlay()
        }
    }
}
