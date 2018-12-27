### 关于
继承自 NSProxy 的代理工具。

### 简介
用于转发消息。

### 使用示例
以最常见的解决 NSTimer 循环引用为例：

```
YAWeakProxy *proxy = [YAWeakProxy proxyWithTarget:self];
self.timer = [NSTimer timerWithTimeInterval:1 target:proxy selector:@selector(print) userInfo:nil repeats:YES];
[NSRunLoop.mainRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
```



