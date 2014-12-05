//
//  ViewController.m
//  JSWeatherAPI
//
//  Created by John Setting on 12/4/14.
//  Copyright (c) 2014 John Setting. All rights reserved.
//

#import "ViewController.h"
#import "JSWeather.h"
#import "JSDailyForecastObject.h"
#import "JSHourlyForecastObject.h"

@interface ViewController () <JSWeatherDelegate>
@property (nonatomic) UIActivityIndicatorView *indicator;
@end

@implementation ViewController
@synthesize indicator;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor blackColor]];
    
    JSWeather *weather = [JSWeather sharedInstance];
    [weather setTemperatureMetric:kJSFahrenheit];
    [weather setDelegate:self];
    [weather getCurrentLocation];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setFrame:CGRectMake(self.view.frame.size.width / 2.0f - indicator.frame.size.width / 2.0f,
                                   self.view.frame.size.height / 2.0f - indicator.frame.size.height / 2.0f,
                                   indicator.frame.size.width, indicator.frame.size.height)];
    [indicator startAnimating];
    [self.view addSubview:indicator];
}

- (void)JSWeather:(JSWeather *)weather didReceiveCurrentLocation:(NSDictionary *)dict
{
    
    NSString *city = [dict objectForKey:@"city"];
    NSString *state = [dict objectForKey:@"state"];
    
    /*
    [weather queryForDailyForecastWithNumberOfDays:14 city:city state:state block:^(NSArray *objects, NSError *error) {
        [indicator stopAnimating];
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
            return;
        }
        
        for (JSDailyForecastObject * obj in objects) {
            NSLog(@"%@", obj.objects);
        }
    }];
    */
    
    /*
    [weather queryForCurrentWeatherWithCity:city state:state block:^(JSCurrentWeatherObject *object, NSError *error) {
        [indicator stopAnimating];
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
            return;
        }
        
        NSLog(@"%@", object.objects);
    }];
    */
    
    /*
    [weather queryForHourlyForecastWithCity:city state:state block:^(NSArray *objects, NSError *error) {
        [indicator stopAnimating];
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
            return;
        }
        
        for (JSHourlyForecastObject * obj in objects) {
            NSLog(@"%@", obj.objects);
        }
    }];
    */
    
}

- (void)JSWeather:(JSWeather *)weather didReceiveCurrentLocationError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
