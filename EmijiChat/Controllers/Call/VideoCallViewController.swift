//
//  VideoCallViewController.swift
//  EmijiChat
//
//  Created by Bender on 31.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class VideoCallViewController: UIViewController {

    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var localVideoView: UIView!
    
    var sinchClient: SINClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         sanbox
         
         // Instantiate a Sinch client object
         sinchClient = Sinch.client(withApplicationKey: "a56e5f5a-4707-4f7c-900a-e0d57da2cf5a",
         applicationSecret: "1dh9TXTPjk2cxRf3kxbFGA==",
         environmentHost: "sandbox.sinch.com",
         userId: "testUserIDBot")
         */
        
        //production
        sinchClient = Sinch.client(withApplicationKey: "7bad6d0a-533d-4003-8fd6-5af140d412d7",
                                   applicationSecret: "3ZpWo3qyREOaOXvW4Lj3pw==",
                                   environmentHost: "clientapi.sinch.com",
                                   userId: FirebaseManager.shared.getCurrentUserID()!)
        
        sinchClient.delegate = self;
        sinchClient.call().delegate = self
        sinchClient.setSupportPushNotifications(true)
        sinchClient.enableManagedPushNotifications()
        sinchClient.setSupportCalling(true)
        sinchClient.start()
        sinchClient.startListeningOnActiveConnection()
        
        let videoController: SINVideoController = sinchClient.videoController()
        self.localVideoView.addSubview(videoController.localView())
        
    }
    
    @IBAction func endVideoCallButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
        sinchClient.call().callUserVideo(withId: "testUserIDBot")
    }
}

extension VideoCallViewController: SINCallClientDelegate, SINCallDelegate, SINClientDelegate, SINManagedPushDelegate {

    func callDidAddVideoTrack(_ call: SINCall!) {
        let videoController: SINVideoController = sinchClient.videoController()
        // Add the video views to your view hierarchy
        remoteVideoView.addSubview(videoController.remoteView())
    }
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        print("😊😊 didReceiveIncomingPushWithPayload\(payload)")
    }
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("😊😊 incoming call")
        call.delegate = self;
        call.answer()
        
        /*
        let storyboard = UIStoryboard(name: "CallViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"CallViewController") as! CallViewController
        self.present(viewController, animated: true)*/
    }
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        print("😊😊 localNotificationForIncomingCall")
        let localNotif = SINLocalNotification()
        localNotif.alertBody = "test alert body"
        localNotif.alertAction = "test alert action"
        return localNotif
    }
    
    func clientDidStart(_ client: SINClient!) {
        print("😊😊 clientDidStart")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("😊😊 clientDidFail")
    }
}
