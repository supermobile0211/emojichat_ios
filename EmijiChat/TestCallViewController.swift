//
//  TestCallViewController.swift
//  EmijiChat
//
//  Created by Bender on 30.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class TestCallViewController: UIViewController {

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
        //commented to test push but is working
        //sinchClient.setSupportActiveConnectionInBackground(true)
        sinchClient.enableManagedPushNotifications()
        sinchClient.setSupportCalling(true)
        sinchClient.start()
        sinchClient.startListeningOnActiveConnection()
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        let callcliet = sinchClient.call()
        _ = callcliet?.callUser(withId: "testUserIDBot")
    }
}

extension TestCallViewController: SINCallClientDelegate, SINCallDelegate, SINClientDelegate, SINManagedPushDelegate {
    /**
     * Tells the delegate that a remote notification was received. The remote notification may be either a VoIP remote
     * push notification, or a regular push remote notification.
     *
     * @param managedPush managed push instance that received the push notification
     * @param payload The dictionary payload that the remote push notification carried.
     * @param pushType SINPushTypeVoIP or SINPushTypeRemote
     */
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        print("😊😊 didReceiveIncomingPushWithPayload\(payload)")
    }
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("😊😊 incoming call")
        call.delegate = self;
        call.answer()
        

//        sinchClient.videoController()
        
        let storyboard = UIStoryboard(name: "CallViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"CallViewController") as! CallViewController
        self.present(viewController, animated: true)
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
