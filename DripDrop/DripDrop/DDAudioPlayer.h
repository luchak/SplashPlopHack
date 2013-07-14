//
//  DDAudioPlayer.h
//  DripDrop
//
//  Created by Matt Stanton on 7/14/13.
//  Copyright (c) 2013 Matt Stanton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDAudioPlayer : NSObject

- (id) init;
- (void) setupAudio;
- (int) numClips;
- (void) playClip:(int)clipId;

@end
