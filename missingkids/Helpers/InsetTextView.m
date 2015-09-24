//
//  InsetTextView.m
//  re:group'd
//
//  Created by Gal Blank on 1/6/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import "InsetTextView.h"

@implementation InsetTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// text position

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 15 , 0 );
}


/*
- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    return [super caretRectForPosition:self.endOfDocument];
}
*/

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"InsetTextView");
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];

}
@end
