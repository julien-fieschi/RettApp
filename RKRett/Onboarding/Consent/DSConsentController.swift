//
//  DSQuizController.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/24/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import ResearchKit
import SVProgressHUD

/**
The `DSConsentController` class defines how the task will be created
*/
class DSConsentController: NSObject {
    
    /**
    The parent UIViewController
    */
    var parentViewController: DSOnboardingViewController!
    
    /**
    The consent ORKTaskViewController
    */
    var consentViewController: ORKTaskViewController!
    
    /**
    The quiz controller
    */
    var quizController = DSQuizController()
    
    /**
    Create a `ORKTaskViewController` and shows it as a child of parentViewController.
    
    :warning: You should always use this controller instead of creating your own `ORKTaskViewController`.
    
    - parameter parentViewController: The UIViewController that will be the ORKTaskViewController's parent.
    - parameter showTask: If the ORKTaskViewController will be displayed after creation.
    
    - returns: `Void`
    */
    func createTaskWithParentViewController(_ parentViewController:DSOnboardingViewController, willShowTask showTask:Bool = true){
        self.consentViewController = ORKTaskViewController(task:DSConsentTask, taskRun: nil)
        self.consentViewController.view.tintColor = .purple
        self.consentViewController.delegate = self
        self.parentViewController = parentViewController
        self.parentViewController.present(self.consentViewController, animated: true, completion: nil)
    }
}

// MARK: - ORKTaskViewControllerDelegate
extension DSConsentController : ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        switch(reason){
        case .completed:
            self.consentViewController.dismiss(animated: true, completion: nil)
            self.parentViewController.proceedToQuiz()
        default:
            self.consentViewController.dismiss(animated: true, completion: nil)
            self.parentViewController.userFailedConsent()
        }
    }
}
