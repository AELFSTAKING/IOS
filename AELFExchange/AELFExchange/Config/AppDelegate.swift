//
//  AppDelegate.swift
//  AELFExchange
//
//  Created by tng on 2019/1/7.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var audioPlayer:AVAudioPlayer?
    private let enableBackgroundRuning = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Setup.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        URLProtocol.registerClass(NetworkIntercepter.self)
        //OConfig.clearAllUIWebViewData(forDomain: "//fixme:the server domain")
        ⚠️⚠️⚠️ WARNING: To run this project, you must resolve all the issue that marked with //fixme: ⚠️⚠️⚠️
        
//        let animationController = LaunchAnimationController()
//        animationController.completion = {
            Config.shared().setup()
            self.window?.rootViewController = MainStoryBoard.instantiateInitialViewController()
            Config.shared().environmentIndicatorSetup()
            AppUpdateManager.shared().checkout { (_) in }
//        }
//        window?.rootViewController = animationController
        
        // Background Running.
        if enableBackgroundRuning {
            if isSimulator { return true }
            DispatchQueue.global().async {
                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setActive(true)
                    try session.setCategory(AVAudioSession.Category.playback)
                    if let bundle = Bundle.main.path(forResource: "mute", ofType: "mp3") {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: bundle))
                        if let audioPlayer = self.audioPlayer {
                            audioPlayer.numberOfLoops = -1
                            audioPlayer.prepareToPlay()
                        }
                    }
                } catch {}
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // For the Background Running.
        if enableBackgroundRuning {
            if let audioPlayer = self.audioPlayer { audioPlayer.play() }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // For the Background Running.
        if enableBackgroundRuning {
            if let audioPlayer = self.audioPlayer, audioPlayer.isPlaying {
                audioPlayer.pause()
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

