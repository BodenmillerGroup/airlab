//
//  ADBPasoCellTableViewCell.m
// AirLab
//
//  Created by Raul Catena on 6/4/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPasoCellTableViewCell.h"
#import "ADBTimerTask.h"
#import "ADBTimersSingleton.h"

@implementation ADBPasoCellTableViewCell

@synthesize cuenta, inprocess;

@synthesize paso = _paso;


-(NSString *)code{
    return [NSString stringWithFormat:@"Recipe%@/%li", _recipe.rcpRecipeId, (long)self.tag];
}

-(void)setPaso:(NSDictionary *)paso{
    _paso = paso;
    self.pasoTexto.text = [[self.paso valueForKey:@"stpText"]stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    float gaps = self.bounds.size.width - self.pasoTexto.bounds.size.width;
    float height = [General calculateHeightedLabelForLabelWithText:_pasoTexto.text andWidth:[self.delegate widthOfVC]-gaps andFontSize:17];
    self.pasoTexto.numberOfLines = 0;
    self.pasoTexto.frame = CGRectMake(_pasoTexto.frame.origin.x, _pasoTexto.frame.origin.y, self.pasoTexto.bounds.size.width, height + 18);
    self.indice.text = [self.paso valueForKey:@"stpPosition"];
    
    if ([[ADBTimersSingleton sharedInstance]timeForTask:[self code]] != 0) {
        self.cuenta = [[ADBTimersSingleton sharedInstance]timeForTask:[self code]];
        [self resumeTimer:nil];
        inprocess = YES;
    }else{
        if (self.tag == _recipe.zetAnchor.integerValue && _recipe.zetSecondsLeft) {
            self.cuenta = self.recipe.zetSecondsLeft.intValue;
        }else{
            self.cuenta = [[self.paso valueForKey:@"stpTime"]intValue];
        }
    }
    
    self.tintColor = [UIColor orangeColor];
    if([self.paso valueForKey:@"stpTime"])
    self.temporizador.text = [General secondsToTime:cuenta];
    else self.temporizador.text = nil;
}

-(void)timeCounter{
    if (cuenta < 0) {
        [self finish:nil];
        self.inprocess = NO;
        self.temporizador.textColor = [UIColor colorWithRed:0.3 green:0.6 blue:0.3 alpha:1];
    }
    int h = floor(((float)cuenta/3600));
    int m = floor(((float)cuenta/60)) - (h*60);
    int s = cuenta - (h*3600) - (m*60);
    NSString *horas = [NSString stringWithFormat:@"%i", h];if(horas.length == 1)horas = [@"0" stringByAppendingString:horas];
    NSString *minutos = [NSString stringWithFormat:@"%i", m];if(minutos.length == 1)minutos = [@"0" stringByAppendingString:minutos];
    NSString *segundos = [NSString stringWithFormat:@"%i", s];if(segundos.length == 1)segundos = [@"0" stringByAppendingString:segundos];
    NSString *string = [NSString stringWithFormat:@"%@:%@:%@", horas, minutos, segundos];
    self.temporizador.text = string;
    if (cuenta>0) {
        cuenta--;
    }
}

-(IBAction)resumeTimer:(id)sender
{
    if (self.cuenta >0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCounter) userInfo:nil repeats:YES];
        [self.timer fire];
        self.temporizador.textColor = [UIColor blueColor];
        
        ADBTimerTask *task = [[ADBTimersSingleton sharedInstance]timerTaskWithCode:[self code]];
        if (!task) {
            task = [[ADBTimerTask alloc]initWithTime:cuenta andMessage:[NSString stringWithFormat:@"The step %@ is over", self.pasoTexto.text] andId:[self code]];
            [[ADBTimersSingleton sharedInstance]addExternalTimer:task];
        }
        [task resume];
    }
}

-(void)cleanTimer{
    ADBTimerTask *task = [[ADBTimersSingleton sharedInstance]timerTaskWithCode:[self code]];
    [task stop];
    self.inprocess = NO;
    [[ADBTimersSingleton sharedInstance]removeFromLine:task];
}

- (IBAction)finish:(id)sender;
{
    [self cleanTimer];
    [self.timer invalidate];
}

@end
