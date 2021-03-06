JSWeatherAPI
============

`JSWeatherAPI` is a helper class to simply pulling weather data into your app.
The Weather API used is 'openWeatherMap'. Since it's free and available for non-commercial and commercial use, I decided that it seemed like the best for independent developers.

<h2>Usage</h2>

<h3>Basic usage</h3>

If you want to simply get the current weather for a city, you can do it like so:
```Objective-C
[JSWeather *weather = [JSWeather sharedInstance];
[weather setTemperatureMetric:kJSFahrenheit];
[weather queryForCurrentWeatherWithCity:@"San Francisco" state:@"CA" block:^(JSCurrentWeatherObject *object, NSError *error) {
    NSLog(@"%@", object.objects);
}];
```
The response you would get back would be

```
2014-12-04 23:05:03.532 JSWeatherAPI[18919:532741] {
    cloudiness = "90.000000";
    "current_temp" = "55.687996";
    humidity = 100;
    image = "<UIImage: 0x7f9ab9643bd0>";
    "location_latitude" = "37.779999";
    "location_longitude" = "-122.419998";
    "max_temp" = "58.999989";
    "min_temp" = "52.519978";
    name = "San Francisco";
    pressure = 1017;
    "sunrise_datetime" = "2014-12-05 15:10:34 +0000";
    "sunset_datetime" = "2014-12-06 00:50:39 +0000";
    weather = Mist;
    "wind_direction" = N;
    "wind_speed" = "1.500000";
}
```

<br><br>


If you want `JSWeather` to help you handle finding the users current location, it does that too! Just be sure to set your info.plist keys `NSLocationWhenInUseUsageDescription`, `privacy - location usage description`, and/or 
 `NSLocationAlwaysUsageDescription` with a user friendly value if your using iOS8!
```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    JSWeather *weather = [JSWeather sharedInstance];
    [weather setTemperatureMetric:kJSFahrenheit];
    [weather setDelegate:self];
    [weather getCurrentLocation];
}

- (void)JSWeather:(JSWeather *)weather didReceiveCurrentLocation:(NSDictionary *)dict
{
    NSString *city = [dict objectForKey:@"city"];
    NSString *state = [dict objectForKey:@"state"];
    
    [weather queryForCurrentWeatherWithCity:city state:state block:^(JSCurrentWeatherObject *object, NSError *error) {
        NSLog(@"%@", object.objects);
    }];
}
```


<br><br>
<h3>Methods/Blocks</h3>
Here is a list of block methods `JSWeather` offers, displaying the basic usage and return value :
<br><br>

<h3>Current Weather</h3>
```Objective-C
- (void)queryForCurrentWeatherWithCity:(NSString *)city state:(NSString *)state
                                 block:(void (^)(JSCurrentWeatherObject *object, NSError *error))completionBlock;
```

```Objective-C
JSWeather *weather = [JSWeather sharedInstance];
[weather setTemperatureMetric:kJSKelvin];
[weather queryForCurrentWeatherWithCity:@"San Francisco" state:@"CA" block:^(JSCurrentWeatherObject *object, NSError *error) {
    NSLog(@"%@", object.objects);
}];
```

```
2014-12-04 23:24:30.700 JSWeatherAPI[19159:541880] {
    cloudiness = "90.000000";
    "current_temp" = "286.309998";
    humidity = 100;
    image = "<UIImage: 0x7f8e4ae1be00>";
    "location_latitude" = "37.779999";
    "location_longitude" = "-122.419998";
    "max_temp" = "288.149994";
    "min_temp" = "284.549988";
    name = "San Francisco";
    pressure = 1017;
    "sunrise_datetime" = "2014-12-05 15:10:34 +0000";
    "sunset_datetime" = "2014-12-06 00:50:39 +0000";
    weather = Mist;
    "wind_direction" = N;
    "wind_speed" = "1.500000";
}
```


<br><br>
<h3>Daily Forecast</h3>
<h4>Note</h4>
When using this block, you can only specify `numberOfDays` as an integer between 1 and 16. If you exceed either integer, the block will return an error object.
```Objective-C
- (void)queryForDailyForecastWithNumberOfDays:(NSInteger)numberOfDays city:(NSString *)city state:(NSString *)state
                        block:(JSWeatherBlock)completionBlock;
```

```Objective-C
JSWeather *weather = [JSWeather sharedInstance];
[weather setTemperatureMetric:kJSFahrenheit];
[weather queryForDailyForecastWithNumberOfDays:2 city:@"San Francisco" state:@"CA" block:^(NSArray *objects, NSError *error) {
    for (JSDailyForecastObject * obj in objects) {
        NSLog(@"%@", obj.objects);
    }
}];
```
```
2014-12-04 23:29:03.016 JSWeatherAPI[19243:544319] {
    cloudiness = "12.000000";
    date = "2014-12-04 20:00:00 +0000";
    day = "55.687996";
    evening = "55.687996";
    humidity = 100;
    image = "<UIImage: 0x7fe67a7257c0>";
    max = "55.687996";
    min = "52.610012";
    morning = "55.687996";
    night = "52.610012";
    pressure = "1020.130005";
    rain = "31.000000";
    "weather_description" = "Heavy Intensity Rain";
    "wind_direction" = NNE;
    "wind_speed" = "1.710000";
}
2014-12-04 23:29:03.017 JSWeatherAPI[19243:544319] {
    cloudiness = "92.000000";
    date = "2014-12-05 20:00:00 +0000";
    day = "61.699989";
    evening = "59.810013";
    humidity = 94;
    image = "<UIImage: 0x7fe67a720e30>";
    max = "61.699989";
    min = "55.418007";
    morning = "55.418007";
    night = "59.360012";
    pressure = "1020.739990";
    rain = "24.000000";
    "weather_description" = "Heavy Intensity Rain";
    "wind_direction" = NNE;
    "wind_speed" = "4.770000";
}
```

<br><br>

<h3>Hourly Forecast</h3>
<h4>NOTE</h4>
Hourly Forecasts will only return 3 hour increments... Sorry about that... Apparently the API doesn't allow for more frequent forecasts

```Objective-C
- (void)queryForHourlyForecastWithCity:(NSString *)city state:(NSString *)state
                                 block:(JSWeatherBlock)block;
```

```Objective-C
JSWeather *weather = [JSWeather sharedInstance];
[weather setTemperatureMetric:kJSCelsius];
[weather queryForHourlyForecastWithCity:@"San Francisco" state:@"CA" block:^(NSArray *objects, NSError *error) {
    for (JSHourlyForecastObject * obj in objects) {
        NSLog(@"%@", obj.objects);
    }
}];
```

```
2014-12-04 23:21:35.588 JSWeatherAPI[19130:540485] {
    cloudiness = "12.000000";
    "current_temp" = "13.040003";
    description = "Few Clouds";
    "ground_level" = "1020.130005";
    "hourly_date" = "2014-12-05 06:00:00 +0000";
    humidity = 97;
    image = "<UIImage: 0x7fe7a2c0ee70>";
    "max_temp" = "13.040003";
    "min_temp" = "12.812006";
    percipitaton = "0.000000";
    pressure = "1020.130005";
    "sea_level" = "1028.849976";
    "wind_direction" = NNE;
    "wind_speed" = "1.710000";
}
2014-12-04 23:21:35.589 JSWeatherAPI[19130:540485] {
    cloudiness = "24.000000";
    "current_temp" = "11.330011";
    description = "Heavy Intensity Rain";
    "ground_level" = "1021.539978";
    "hourly_date" = "2014-12-05 09:00:00 +0000";
    humidity = 99;
    image = "<UIImage: 0x7fe7a2e6f0d0>";
    "max_temp" = "11.330011";
    "min_temp" = "11.115992";
    percipitaton = "31.000000";
    pressure = "1021.539978";
    "sea_level" = "1030.339966";
    "wind_direction" = NNE;
    "wind_speed" = "2.610000";
}
...
...
...
```

<br><br>
<h3>Historical Data</h3>
```Objective-C
- (void)queryForHistoricalDataWithCity:(NSString *)city state:(NSString *)state
                                 block:(JSWeatherBlock)block;
```

```Objective-C
JSWeather *weather = [JSWeather sharedInstance];
[weather setTemperatureMetric:kJSFahrenheit];
[weather queryForHistoricalDataWithCity:@"San Francisco" state:@"CA" block:^(NSArray *objects, NSError *error) {
    for (JSHistoricalDataObject * obj in objects) {
        NSLog(@"%@", obj.objects);
    }
}];
```

```
2014-12-05 14:15:02.201 Example[2474:59398] {
    "beginning_wind_direction" = NNE;
    cloudiness = "75.000000";
    "current_temp" = "44.383999";
    date = "2014-12-04 19:37:11 +0000";
    "ending_wind_direction" = N;
    humidity = 36;
    image = "<UIImage: 0x7f8371f0b960>";
    "max_temp" = "46.399990";
    "min_temp" = "40.999989";
    pressure = "1028.000000";
    "weather_description" = "Broken Clouds";
    "wind_direction" = NNE;
    "wind_speed" = "4.600000";
}
2014-12-05 14:15:02.202 Example[2474:59398] {
    "beginning_wind_direction" = N;
    cloudiness = "90.000000";
    "current_temp" = "43.268005";
    date = "2014-12-04 20:36:24 +0000";
    "ending_wind_direction" = N;
    humidity = 39;
    image = "<UIImage: 0x7f8371d74ea0>";
    "max_temp" = "44.599991";
    "min_temp" = "39.199989";
    pressure = "1028.000000";
    "weather_description" = "Overcast Clouds";
    "wind_direction" = NNE;
    "wind_speed" = "4.100000";
}
...
...
...
```

<br><br>
<h2>Requirements</h2>
- iOS 7 or higher
- Automatic Reference Counting (ARC)
<br><br>

<h2>Author</h2>
- [John Setting](http://github.com/jsetting32) ([Facebook](https://www.facebook.com/jsetting23))
<br><br>

<h2>License</h2>
JSWeatherAPI is released under the MIT license. See the LICENSE file for more info.
