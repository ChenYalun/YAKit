### 关于
以Block的形式获取用户所在位置

### 使用

#### 直接获取位置
    YALocationManager *manager = [YALocationManager sharedManager];
    [manager requestLocationWithCompletion:^(CLLocation *location, CLPlacemark *place, NSError *error) {
       // do something.
    }];
    
#### 单独请求位置权限

    [[YALocationManager sharedManager] requestAuthorization];


### 扩展
#### 没有权限的处理

     if (error.code == kCLErrorDenied) {
            UIAlertAction *actionOpen = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL: url];
                }
            }];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"没有位置权限" message:@"前往设置页面打开定位" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:actionOpen];
            [alertController addAction:actionCancel];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        

