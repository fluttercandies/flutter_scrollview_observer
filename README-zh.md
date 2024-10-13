![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/banner.png)

# Flutter ScrollView Observer

[![author](https://img.shields.io/badge/author-LinXunFeng-blue.svg?style=flat-square&logo=Iconify)](https://github.com/LinXunFeng/) [![pub](https://img.shields.io/pub/v/scrollview_observer?&style=flat-square&label=pub&logo=dart)](https://pub.dev/packages/scrollview_observer) [![stars](https://img.shields.io/github/stars/fluttercandies/flutter_scrollview_observer?style=flat-square&logo=github)](https://github.com/fluttercandies/flutter_scrollview_observer)

Language: 中文 | [English](https://github.com/fluttercandies/flutter_scrollview_observer)

这是一个可用于监听滚动视图中正在显示的子部件的组件库。

## ☕ 请我喝一杯咖啡

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/T6T4JKVRP) [![wechat](https://img.shields.io/static/v1?label=WeChat&message=微信收款码&color=brightgreen&style=for-the-badge&logo=WeChat)](https://cdn.jsdelivr.net/gh/FullStackAction/PicBed@resource20220417121922/image/202303181116760.jpeg)

微信技术交流群请看: [【微信群说明】](https://mp.weixin.qq.com/s/JBbMstn0qW6M71hh-BRKzw)

## 📖 文章

- [Flutter - 获取ListView当前正在显示的Widget信息](https://mp.weixin.qq.com/s/cN3qeinBPlo5rtEpoQBVVA) | [备用链接](https://juejin.cn/post/7103058155692621837)
- [Flutter - 列表滚动定位超强辅助库，墙裂推荐！🔥](https://mp.weixin.qq.com/s/fplqfBpXwvx6mEO6vflkww) | [备用链接](https://juejin.cn/post/7129888644290068487)
- [Flutter - 快速实现聊天会话列表的效果，完美💯](https://mp.weixin.qq.com/s/xNiGuSLcJtDAiLoHuGWp6A) | [备用链接](https://juejin.cn/post/7152307272436154405)
- [Flutter - 船新升级😱支持观察第三方构建的滚动视图💪](https://mp.weixin.qq.com/s/FMXPyT-lX8YOXVmbLCsVUA) | [备用链接](https://juejin.cn/post/7240751116702269477)
- [Flutter - 瀑布流交替播放视频 🎞](https://mp.weixin.qq.com/s/miP5CfKtcRhFGr08ot5wOg) | [备用链接](https://juejin.cn/post/7243240589293142077)
- [Flutter - IM保持消息位置大升级(支持ChatGPT生成式消息) 🤖](https://mp.weixin.qq.com/s/Y3EN9ZpLb6HLke2vkw0Zwg) | [备用链接](https://juejin.cn/post/7245753944180523067)
- [Flutter - 滚动视图中的表单防遮挡 🗒](https://mp.weixin.qq.com/s/iaHyYMjZSPBggLw2yZv8dQ) | [备用链接](https://juejin.cn/spost/7266455050632921107)
- [Flutter - 秒杀1/2曝光统计 📊](https://mp.weixin.qq.com/s/gNFX4Au4esftgTPXHvB4LQ) | [备用链接](https://juejin.cn/post/7271248528998121512)
- [Flutter - 如何快速搓一个微信通讯录列表(azlist) 📓](https://mp.weixin.qq.com/s/1bmYSvtOYX83DLncvnBjqA) | [备用链接](https://juejin.cn/post/7294884963631497254)
- [Flutter - 支持观察NestedScrollView，兼容性更强 😈](https://mp.weixin.qq.com/s/1dsmRg8q2VJ6HzasLgoVpA) | [备用链接](https://juejin.cn/post/7388444606456840211)
- [Flutter - 轻松实现PageView卡片偏移效果](https://mp.weixin.qq.com/s/Q8zk89bgr_8bgWQ4F86VUQ) | [备用链接](https://juejin.cn/post/7411516362916216859)
- [Flutter - 轻松搞定炫酷视差(Parallax)效果](https://mp.weixin.qq.com/s/Fi-X2eJRWj17sqCcVqbPRQ) | [备用链接](https://juejin.cn/post/7416655730214699017)

## 🔨 功能点

> 不需要改变你当前所使用视图，只需要在视图外包裹一层即可实现如下功能点

- [x] 监听滚动视图中正在显示的子部件
- [x] 支持滚动到指定下标位置
- [x] 快速实现聊天会话列表的效果
- [x] 支持在插入或更新消息时保持IM消息位置，避免抖动

## 🎀 支持

- [x] `PageView`
- [x] `ListView`
- [x] `SliverList`
- [x] `GridView`
- [x] `SliverGrid`
- [x] 支持 `SliverPersistentHeader`，`SliverList` 和 `SliverGrid` 混合使用
- [x] `NestedScrollView`
- [x] 由第三方库构建的 `ScrollView`

## 🕹 预览

- 🖥 [在线预览](https://fluttercandies.github.io/flutter_scrollview_observer/)
- 🏞 [示例图片](https://github.com/fluttercandies/flutter_scrollview_observer/wiki/Example)

## 📦 安装

在你的 `pubspec.yaml` 文件中添加 `scrollview_observer` 依赖:

```yaml
dependencies:
  scrollview_observer: latest_version
```

在需要使用的地方导入 `scrollview_observer` :

```dart
import 'package:scrollview_observer/scrollview_observer.dart';
```

## 📚 指南
- [Wiki首页](https://github.com/fluttercandies/flutter_scrollview_observer/wiki/%E9%A6%96%E9%A1%B5)
- [1、监听滚动视图中正在显示的子部件](https://github.com/fluttercandies/flutter_scrollview_observer/wiki/1%E3%80%81%E7%9B%91%E5%90%AC%E6%BB%9A%E5%8A%A8%E8%A7%86%E5%9B%BE%E4%B8%AD%E6%AD%A3%E5%9C%A8%E6%98%BE%E7%A4%BA%E7%9A%84%E5%AD%90%E9%83%A8%E4%BB%B6)
- [2、滚动到指定下标位置](https://github.com/fluttercandies/flutter_scrollview_observer/wiki/2%E3%80%81%E6%BB%9A%E5%8A%A8%E5%88%B0%E6%8C%87%E5%AE%9A%E4%B8%8B%E6%A0%87%E4%BD%8D%E7%BD%AE)
- [3、聊天会话](https://github.com/fluttercandies/flutter_scrollview_observer/wiki/3%E3%80%81%E8%81%8A%E5%A4%A9%E4%BC%9A%E8%AF%9D)



## 🖨 关于我

- GitHub: [https://github.com/LinXunFeng](https://github.com/LinXunFeng)
- Email: [linxunfeng@yeah.net](mailto:linxunfeng@yeah.net)
- Blogs: 
  - 全栈行动: [https://fullstackaction.com](https://fullstackaction.com)
  - 掘金: [https://juejin.cn/user/1820446984512392](https://juejin.cn/user/1820446984512392) 

<img height="267.5" width="481.5" src="https://github.com/LinXunFeng/LinXunFeng/raw/master/static/img/FSAQR.png"/>
