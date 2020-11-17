//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/5/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView  {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniEpisodeTitleLabel: UILabel!
    @IBOutlet weak var miniplayerView: UIView!
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    @IBOutlet weak var soundSlider: UISlider!
    
    
    @IBOutlet weak var miniEpisodeForward: UIButton!{
        didSet{
            miniEpisodeForward.addTarget(self, action: #selector(handleforward), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var forwardEpisode: UIButton!{
        didSet{
            forwardEpisode.addTarget(self, action: #selector(handleforward), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var miniEpisodePlayPause: UIButton!{
        didSet{
            miniEpisodePlayPause.addTarget(self, action: #selector(playPauseButton), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var playAndPause: UIButton!{
        didSet{
            playAndPause.addTarget(self, action: #selector(playPauseButton), for: .touchUpInside)
        }
    }
    
    
    @IBOutlet weak var episodeimageView: UIImageView!{
        didSet{

            episodeimageView.transform = shrunkenTransform
        }
    }
    
    var playEpisodes           = [Episode]()
    let shrunkenTransform     = CGAffineTransform(scaleX: 0.7, y: 0.7)
    var panGesture: UIPanGestureRecognizer!
    
    /// obj of struct  to acsess api
    var episode :Episode! {
        didSet{
            
            fetchdataEpisdoe()
        }
    }
    
    var player:AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    fileprivate func observeBoundaryTime() {
        let time     = CMTimeMake(value: 1, timescale: 3)
        let times    = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {[weak self] in
            self?.enlargeEpisodeImageView()
            self?.setupLockscreenDuration()
        }
    }
    ///       show timw of podcast on lockscreen      setupLockscreenCurrentTime()
    
    fileprivate func setupLockscreenDuration(){
        guard let duration = player.currentItem?.duration else {return}
        let durationSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
        
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        setupGesture()
        observerPlayerCurrentTime()
        setupRemoteControl()

        observeBoundaryTime()
        //this func to do something it when do any this same ay 7ad atsl ow 48alt a5nya an podcast y3mal stop
        setupInterruptionObserve()
    }

    static func initFromNib()->PlayerDetailsView{
        return Bundle.main.loadNibNamed("player", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
   
    //MARK: - fetch data form api and rss
    
    fileprivate  func fetchdataEpisdoe(){
        miniEpisodeTitleLabel.text = episode.title
        titleLabel.text    = episode.title
        authorLabel.text   = episode.author
        guard let url      = URL(string: episode.imageURL ?? "") else{return}
        
        setupNowPlayingInfo()
        setupAudioSession()

        playEpisode()
        
        episodeimageView.sd_setImage(with: url, completed: nil)
        // miniEpisodeImageView.sd_setImage(with: url, completed: nil)
        // this code make image podcast work in the lockscrren
        miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
            guard let image = image else {return}
            
            //lockscreen artwork setup code
            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
            
            // some modifications here
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { (_) -> UIImage in
                return image
            }
            
            nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    // play Av from api
    fileprivate func playEpisode(){
        if episode.fileUrl != nil{
            // play episode offline and storge in localstorge
             playEpisodeUsingFileUrl()
        }else{
        guard let url    = URL(string: episode.streamUrl)else{return}
        let playItem     = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playItem)
        player.play()
        
    }
}
    //MARK: - play episode offline and storge in localstorge
    fileprivate func playEpisodeUsingFileUrl(){
        // play episode offline and storge in localstorge
        guard let fileURL = URL(string: episode.fileUrl ?? "" ) else {return}
             let fileName = fileURL.lastPathComponent
             
             guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{return}
             trueLocation.appendPathComponent(fileName)
        
                  let playItem     = AVPlayerItem(url: trueLocation)
                  player.replaceCurrentItem(with: playItem)
                  player.play()
             
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //MARK: - MediaPlayer
    // to Play podcast on background
    
    fileprivate func setupAudioSession(){
        do{
            try  AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try  AVAudioSession.sharedInstance().setActive(true)
        }catch let error{
            print("Failed to activate session:",error)
        }
    }
    
    // to button work on background
    fileprivate func setupRemoteControl(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commendCenter = MPRemoteCommandCenter.shared()
        commendCenter.playCommand.isEnabled  = true
        commendCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playAndPause.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.miniEpisodePlayPause.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            //when i play in lock screen when i play play when i stop no more add sec
            self.setupElapsedTime(playbackRate: 1)
            return .success
        }
        
        commendCenter.pauseCommand.isEnabled = true
        commendCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playAndPause.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            self.miniEpisodePlayPause.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            //when i stop in lock screen when i play play when i stop no more add sec
            self.setupElapsedTime(playbackRate: 0)
            return .success
        
        }
        // for boutton on headphone to stop podcast
        commendCenter.togglePlayPauseCommand.isEnabled = true
        commendCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPauseButton(self)
            //            if self.player.timeControlStatus == .playing{
            //                self.player.pause()
            //            }else{
            //                 self.player.play()
            //            }
            //
            return .success
        }
        commendCenter.nextTrackCommand.addTarget(self, action: #selector(handelNextTrack))
        commendCenter.previousTrackCommand.addTarget(self, action: #selector(handelpreviousTrack))
        
    }
    // befor button of the lockScreen
    @objc fileprivate func handelpreviousTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
      if playEpisodes.isEmpty {
        return .noSuchContent
      }
      
      let currentEpisodeIndex = playEpisodes.firstIndex { (ep) -> Bool in
        return self.episode.title == ep.title && self.episode.author == ep.author
      }
      guard let index = currentEpisodeIndex else { return .noSuchContent }
      let prevEpisode: Episode
      if index == 0 {
        let count = playEpisodes.count
        prevEpisode = playEpisodes[count - 1]
      } else {
        prevEpisode = playEpisodes[index - 1]
      }
      self.episode = prevEpisode
      return .success
    }
//    @objc func  handelpreviousTrack()-> MPRemoteCommandHandlerStatus{
//
//
//        if playEpisodes.count == 0 {return MPRemoteCommandHandlerStatus(rawValue: 1)!}
//        let currentEpisodeIndex = playEpisodes.lastIndex { (ep) -> Bool in
//            return self.episode.title == ep.title && episode.author == ep.author
//        }
//        guard let index = currentEpisodeIndex else{return MPRemoteCommandHandlerStatus(rawValue: 1)!}
//        let nextEpisode:Episode
//        if index == playEpisodes.count - 1 {
//            nextEpisode = playEpisodes[0]
//        }else{
//            nextEpisode = playEpisodes[index - 1]
//        }
//        self.episode = nextEpisode
//        return .success
//
//    }
    
    // next button of the lockScreen
    @objc fileprivate func handelNextTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
      if playEpisodes.count == 0 {
        return .noSuchContent
      }
      
      let currentEpisodeIndex = playEpisodes.firstIndex { (ep) -> Bool in
        return self.episode.title == ep.title && self.episode.author == ep.author
      }
      
      guard let index = currentEpisodeIndex else { return .noSuchContent }
      
      let nextEpisode: Episode
      if index == playEpisodes.count - 1 {
        nextEpisode = playEpisodes[0]
      } else {
        nextEpisode = playEpisodes[index + 1]
      }
      
      self.episode = nextEpisode
      return .success
    }
    
//    @objc func handelNextTrack()-> MPRemoteCommandHandlerStatus{
//
//        if playEpisodes.count == 0 {return MPRemoteCommandHandlerStatus(rawValue: 1)!}
//        let currentEpisodeIndex = playEpisodes.firstIndex { (ep) -> Bool in
//            return self.episode.title == ep.title && episode.author == ep.author
//        }
//        guard let index = currentEpisodeIndex else{return MPRemoteCommandHandlerStatus(rawValue: 1)!}
//        let nextEpisode:Episode
//        if index == playEpisodes.count - 1 {
//            nextEpisode = playEpisodes[0]
//        }else{
//            nextEpisode = playEpisodes[index + 1]
//        }
//        self.episode = nextEpisode
//        return .success
//
//    }
    
    fileprivate func setupElapsedTime(playbackRate:Float){
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate ] = playbackRate

    }
    
    
    
    //AVAudioSessionInterruption
       func  setupInterruptionObserve()
       {
           NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
       }
       
       @objc func handleInterruption(notification :Notification){
           
           guard let  userInfo = notification.userInfo else { return }
           guard let type = userInfo[AVAudioSessionInterruptionTypeKey]  as? UInt else { return }

           if type == AVAudioSession.InterruptionType.began.rawValue{
               playAndPause.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
               miniEpisodePlayPause.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
              
           }else{
                guard let options = userInfo[AVAudioSessionInterruptionOptionKey]  as? UInt else { return }
               if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue{
                   player.play()
                              playAndPause.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
                             miniEpisodePlayPause.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
               }
              
           }
       }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    //MARK: -  GestureRecognize
    
    fileprivate func setupGesture() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelTabMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniplayerView.addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(hendleDimissPan)))
    }
    
    @objc func hendleDimissPan(gesture:UIPanGestureRecognizer){
        if  gesture.state  == .changed{
            let transaltion      = gesture.translation(in: superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: transaltion.y)
        } else if gesture.state  == .ended{
            let transaltion = gesture.translation(in: superview)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7,initialSpringVelocity: 1,options: .curveEaseOut, animations: {
                self.maximizedStackView.transform = .identity
                if transaltion.y > 50{
                   
                    UIApplication.mainTabaBarController()?.minimizedPlayerDetails()
                    
                }
            })
        }
    }
    
    
    fileprivate func handlePanEnded(_ gesture: UIPanGestureRecognizer) {
        let translation      = gesture.translation(in: self.superview)
        let velocity         = gesture.velocity(in: self.superview)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform   = .identity
            
            if translation.y < -200 || velocity.y > -500{
                UIApplication.mainTabaBarController()?.maximizedPlayerDetails(episode: nil)
                
            }else{
                
                self.miniplayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        })
    }
    
    fileprivate func handelPanChanged(_ gesture: UIPanGestureRecognizer) {
        let translation     = gesture.translation(in: self.superview)
        self.transform      = CGAffineTransform(translationX: 0, y: translation.y)
        
        self.miniplayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    @objc func handlePan(gesture:UIPanGestureRecognizer){
        if gesture.state == .changed{
            handelPanChanged(gesture)
            
        }else if gesture.state == .ended{
            handlePanEnded(gesture)
        }
    }
    
    @objc func handelTabMaximize(){
        UIApplication.mainTabaBarController()?.maximizedPlayerDetails(episode: nil)
    }
    
    
    //play podcast in lockscreen
    
    fileprivate func  setupNowPlayingInfo(){
        var nowPlayingInfo = [String:Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - animate
    
    fileprivate func enlargeEpisodeImageView(){
        UIView.animate(withDuration: 0.75, delay: 0,usingSpringWithDamping: 0.7 ,initialSpringVelocity: 1,options:.curveEaseOut, animations: {
            self.episodeimageView.transform = .identity
        })
    }
    
    
    fileprivate func shrinkEpisodeImageView(){
        UIView.animate(withDuration: 0.75, delay: 0,usingSpringWithDamping: 0.7 ,initialSpringVelocity: 1,options:.curveEaseOut, animations: {
            self.episodeimageView.transform = self.shrunkenTransform
            
        })
        
    }
    
    //MARK: - calculation time
    
    fileprivate func observerPlayerCurrentTime(){
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] (time) in
            
            self?.currentLabel.text     = time.toDisplayString()
            let durationTime            = self?.player.currentItem?.duration
            self?.durationLabel.text    = durationTime?.toDisplayString()
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    func updateCurrentTimeSlider(){
        let currentSecond      = CMTimeGetSeconds(player.currentTime())
        let durationSecond     = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentSecond / durationSecond
        self.currentTimeSlider.value  = Float(percentage)
    }
    
    
    
    fileprivate func seekCurrentTime(time:Int64) {
        let fifteenSecond      = CMTimeMake(value: time, timescale: 1)
        let seekTime           = CMTimeAdd(player.currentTime(), fifteenSecond)
        player.seek(to: seekTime)
    }
    
    
    
    
    //MARK: - IB Action
    @objc func playPauseButton(_ sender: Any) {
        
        if player.timeControlStatus == .paused{
            player.play()
            playAndPause.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            miniEpisodePlayPause.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            enlargeEpisodeImageView()
            self.setupElapsedTime(playbackRate: 1)

            
        }else{
            player.pause()
            playAndPause.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            miniEpisodePlayPause.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)

            shrinkEpisodeImageView()
            self.setupElapsedTime(playbackRate: 0)

        }
    }
    
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage          = currentTimeSlider.value
        guard let duration      = player.currentItem?.duration else {return}
        let durationInSecond    = CMTimeGetSeconds(duration)
        let seekingTimeInSecond = Float64(percentage) * durationInSecond
        let seekTime            = CMTimeMakeWithSeconds(seekingTimeInSecond, preferredTimescale: 1)
        
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekingTimeInSecond
        player.seek(to: seekTime)
    }
    
    
    @IBAction func handlebackword(_ sender: Any) {
        seekCurrentTime(time: -15)
    }
    
    
    
    @objc func handleforward(_ sender: Any) {
        seekCurrentTime(time: 15)
    }
    
    
    @IBAction func handleVolumeChange(_ sender: UISlider ) {

            player.volume = sender.value
        
    }
    
    @IBAction func dismss(_ sender: Any) {
        UIApplication.mainTabaBarController()?.minimizedPlayerDetails()
        
    }
}



