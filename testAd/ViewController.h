//
//  ViewController.h
//  testAd
//
//  Created by Jacob on 15/12/10.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRController.h"



@interface ViewController : UIViewController < MRControllerDelegate>
{
    MRController *mrController;
}

@end

