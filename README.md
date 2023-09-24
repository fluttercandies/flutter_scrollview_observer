# Flutter ScrollView Observer

[![author](https://img.shields.io/badge/author-LinXunFeng-blue.svg?style=flat-square&logo=Iconify)](https://github.com/LinXunFeng/) [![pub](https://img.shields.io/pub/v/scrollview_observer?&style=flat-square&label=pub&logo=dart)](https://pub.dev/packages/scrollview_observer) [![stars](https://img.shields.io/github/stars/LinXunFeng/flutter_scrollview_observer?style=flat-square&logo=github)](https://github.com/LinXunFeng/flutter_scrollview_observer)

Language: English | [中文](https://github.com/LinXunFeng/flutter_scrollview_observer/blob/main/README-zh.md)


This is a library of widget that can be used to listen for child widgets those are being displayed in the scroll view.

## ☕ Support me

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/T6T4JKVRP) [![wechat](https://img.shields.io/static/v1?label=WeChat&message=WeChat&nbsp;Pay&color=brightgreen&style=for-the-badge&logo=WeChat)](https://cdn.jsdelivr.net/gh/FullStackAction/PicBed@resource20220417121922/image/202303181116760.jpeg)

Chat: [Join WeChat group](https://mp.weixin.qq.com/s/JBbMstn0qW6M71hh-BRKzw)

## 📖 Article

- [Flutter - 获取ListView当前正在显示的Widget信息](https://mp.weixin.qq.com/s/cN3qeinBPlo5rtEpoQBVVA) | [备用链接](https://juejin.cn/post/7103058155692621837)
- [Flutter - 列表滚动定位超强辅助库，墙裂推荐！🔥](https://mp.weixin.qq.com/s/fplqfBpXwvx6mEO6vflkww) | [备用链接](https://juejin.cn/post/7129888644290068487)
- [Flutter - 快速实现聊天会话列表的效果，完美💯](https://mp.weixin.qq.com/s/xNiGuSLcJtDAiLoHuGWp6A) | [备用链接](https://juejin.cn/post/7152307272436154405)
- [Flutter - 船新升级😱支持观察第三方构建的滚动视图💪](https://mp.weixin.qq.com/s/FMXPyT-lX8YOXVmbLCsVUA) | [备用链接](https://juejin.cn/post/7240751116702269477)
- [Flutter - 瀑布流交替播放视频 🎞](https://mp.weixin.qq.com/s/miP5CfKtcRhFGr08ot5wOg) | [备用链接](https://juejin.cn/post/7243240589293142077)
- [Flutter - IM保持消息位置大升级(支持ChatGPT生成式消息) 🤖](https://mp.weixin.qq.com/s/Y3EN9ZpLb6HLke2vkw0Zwg) | [备用链接](https://juejin.cn/post/7245753944180523067)
- [Flutter - 滚动视图中的表单防遮挡 🗒](https://mp.weixin.qq.com/s/iaHyYMjZSPBggLw2yZv8dQ) | [备用链接](https://juejin.cn/spost/7266455050632921107)
- [Flutter - 秒杀1/2曝光统计 📊](https://mp.weixin.qq.com/s/gNFX4Au4esftgTPXHvB4LQ) | [备用链接](https://juejin.cn/post/7271248528998121512)

## 🔨 Feature

> You do not need to change the view you are currently using, just wrap a `ViewObserver` around the view to achieve the following features.

- [x] Observing child widgets those are being displayed in ScrollView
- [x] Support for scrolling to a specific item in ScrollView
- [x] Quickly implement the chat session page effect
- [x] Support for keeping IM message position when inserting or updating messages, avoiding jitter.

## 🎀 Support

- [x] `ListView`
- [x] `SliverList`
- [x] `GridView`
- [x] `SliverGrid` 
- [x] Mixing usage of `SliverPersistentHeader`, `SliverList` and `SliverGrid`
- [x] `ScrollView` built by third-party package.

## 📦 Installing

Add `scrollview_observer` to your pubspec.yaml file:


```yaml
dependencies:
  scrollview_observer: latest_version
```

Import `scrollview_observer` in files that it will be used:

```dart
import 'package:scrollview_observer/scrollview_observer.dart';
```

## 📚 Wiki

- [Wiki Home](https://github.com/LinXunFeng/flutter_scrollview_observer/wiki)
- [Example](https://github.com/LinXunFeng/flutter_scrollview_observer/wiki/Example)
- [1、Observing child widgets those are being displayed in the scroll view](https://github.com/LinXunFeng/flutter_scrollview_observer/wiki/1%E3%80%81Observing-child-widgets-those-are-being-displayed-in-the-scroll-view)
- [2、Scrolling to the specified index location](https://github.com/LinXunFeng/flutter_scrollview_observer/wiki/2%E3%80%81Scrolling-to-the-specified-index-location)
- [3、Chat Observer](https://github.com/LinXunFeng/flutter_scrollview_observer/wiki/3%E3%80%81Chat-Observer)

## 🖨 About Me

- GitHub: [https://github.com/LinXunFeng](https://github.com/LinXunFeng)
- Email: [linxunfeng@yeah.net](mailto:linxunfeng@yeah.net)
- Blogs: 
  - 全栈行动: [https://fullstackaction.com](https://fullstackaction.com)
  - 掘金: [https://juejin.cn/user/1820446984512392](https://juejin.cn/user/1820446984512392) 

<img height="267.5" width="481.5" src="https://github.com/LinXunFeng/LinXunFeng/raw/master/static/img/FSAQR.png"/>