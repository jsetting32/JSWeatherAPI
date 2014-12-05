//
//  JSWeather.m
//  JSWeatherAPI
//
//  Created by John Setting on 12/4/14.
//  Copyright (c) 2014 John Setting. All rights reserved.
//

#import "JSWeather.h"
#import "JSWeatherConstants.h"
#import "JSWeather.h"
#import "JSWeatherUtility.h"

@interface JSWeather() <JSCurrentLocationDelegate>
@property (nonatomic, strong) JSCurrentLocation *JSLocation;
@end

@implementation JSWeather

+(id)sharedInstance
{
    static dispatch_once_t once;
    static JSWeather *instance;
    dispatch_once(&once, ^{ instance = [[JSWeather alloc] init]; });
    return instance;

}

- (void)getCurrentLocation
{
    self.JSLocation = [JSCurrentLocation sharedInstance];
    [self.JSLocation setDelegate:self];
    [self.JSLocation getCurrentLocation];
}

- (void)queryForCurrentWeatherAndImageByCoordinates:(NSString *)city state:(NSString *)state
                                              block:(void (^)(JSCurrentWeatherObject *object, NSError *error))completionBlock
{
    NSString *query = [[NSString stringWithFormat:@"%@%@%@%@%@,%@",
                        kJSWeatherAPIURL, kJSWeatherAPITypeData, kJSWeatherAPIVersion, kJSWeatherAPIQueryWeather,city, state] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:query]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   completionBlock(nil, error);
                                   return;
                               }
                               
                               NSMutableDictionary * json = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
                               NSDictionary *theWeather = [[json objectForKey:@"weather"] firstObject];
                               
                               NSString *query = [[NSString stringWithFormat:@"%@%@%@.png",
                                                   kJSWeatherURL, kJSWeatherAPITypeImage, [theWeather objectForKey:@"icon"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                               [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:query]]
                                                                  queue:[NSOperationQueue mainQueue]
                                                      completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                                          [json setObject:[UIImage imageWithData:data] forKey:@"image"];
                                                          JSCurrentWeatherObject *object = [[JSCurrentWeatherObject alloc] initWithData:json temperatureConversion:self.temperatureMetric];
                                                          completionBlock(object, nil);
                                                          return;
                                                      }];
                               return;
                           }];
}

- (void)queryForDailyForecastWithNumberOfDays:(NSInteger)numberOfDays city:(NSString *)city state:(NSString *)state
                                        block:(void (^)(NSArray *objects, NSError *error))completionBlock
{
    if (numberOfDays > 16 || numberOfDays < 1) {
        NSString *reason = [NSString stringWithFormat:@"Cannot ask for %li days of daily forecast information. It must be greater than 1 and less than 17.", (long)numberOfDays];
        NSError *error = [NSError errorWithDomain:@"com.JSWeather.api"
                                             code:301
                                         userInfo:@{
                                                    NSLocalizedFailureReasonErrorKey:reason, NSLocalizedFailureReasonErrorKey:reason,
                                                    NSLocalizedRecoverySuggestionErrorKey:@"Make sure the numberOfDays passed is between 1 and 16"}];
        completionBlock(nil, error);
        return;
    }
    
    
    NSString *query = [[NSString stringWithFormat:@"%@%@%@%@%@,%@&%@%li",
                        kJSWeatherAPIURL, kJSWeatherAPITypeData, kJSWeatherAPIVersion, kJSWeatherAPIQueryDailyForecast,city, state, kJSWeatherAPIQueryDailyForecastCount, (long)numberOfDays] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:query]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               if (error) {
                                   completionBlock(nil, error);
                                   return;
                               }
                               
                               NSMutableDictionary * json = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
                               
                               NSMutableArray *arr = [NSMutableArray array];
                               for (NSDictionary * dict in [json objectForKey:@"list"]) {
                                   NSString *query = [[NSString stringWithFormat:@"%@%@%@.png",
                                                       kJSWeatherURL, kJSWeatherAPITypeImage, [[[dict objectForKey:@"weather"] firstObject] objectForKey:@"icon"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                   NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:dict];
                                   [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:query]]
                                                                      queue:[NSOperationQueue mainQueue]
                                                          completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                                              
                                                              if (error) {
                                                                  completionBlock(nil, error);
                                                                  return;
                                                              }

                                                              [d setObject:[UIImage imageWithData:data] forKey:@"image"];
                                                              JSDailyForecastObject *object = [[JSDailyForecastObject alloc] initWithData:d temperatureConversion:self.temperatureMetric];
                                                              [arr addObject:object];
                                                              if ([arr count] == numberOfDays) {
                                                                  
                                                                  [arr sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"objects.date"  ascending:YES]]];

                                                                  completionBlock(arr, nil);
                                                                  return;
                                                              }
                                                          }];
                               }
                               
                           }];
}

- (void)queryForHourlyForecast:(NSString *)city state:(NSString *)state
                         block:(void (^)(NSArray *objects, NSError *error))completionBlock
{
    NSString *query = [[NSString stringWithFormat:@"%@%@%@%@%@,%@",
                        kJSWeatherAPIURL, kJSWeatherAPITypeData, kJSWeatherAPIVersion, kJSWeatherAPIQueryHourlyForecast,city, state] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:query]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               if (error) {
                                   completionBlock(nil, error);
                                   return;
                               }
                               
                               NSMutableDictionary * json = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
                               
                               NSMutableArray *arr = [NSMutableArray array];
                               
                               for (NSDictionary * dict in [json objectForKey:@"list"]) {
                                   NSString *query = [[NSString stringWithFormat:@"%@%@%@.png",
                                                       kJSWeatherURL, kJSWeatherAPITypeImage, [[[dict objectForKey:@"weather"] firstObject] objectForKey:@"icon"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                   NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:dict];
                                   [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:query]]
                                                                      queue:[NSOperationQueue mainQueue]
                                                          completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                                              
                                                              if (error) {
                                                                  completionBlock(nil, error);
                                                                  return;
                                                              }
                                                              
                                                              [d setObject:[UIImage imageWithData:data] forKey:@"image"];
                                                              JSHourlyForecastObject *object = [[JSHourlyForecastObject alloc] initWithData:d temperatureConversion:self.temperatureMetric];
                                                              [arr addObject:object];
                                                              if ([arr count] == [[json objectForKey:@"list"] count]) {

                                                                  [arr sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"objects.hourly_date"  ascending:YES]]];
                                                                  
                                                                  completionBlock(arr, nil);
                                                                  return;
                                                              }
                                                          }];
                               }
                           }];
}



- (void)JSCurrentLocation:(JSCurrentLocation *)object didFailToReceiveLocation:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(JSWeather:didReceiveCurrentLocationError:)]) {
        [self.delegate JSWeather:self didReceiveCurrentLocationError:error];
    }
}


- (void)JSCurrentLocation:(JSCurrentLocation *)object didReceiveLocation:(NSDictionary *)location
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(JSWeather:didReceiveCurrentLocation:)]) {
        [self.delegate JSWeather:self didReceiveCurrentLocation:location];
    }
}

@end
