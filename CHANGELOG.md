## 1.21.2
- Observer Widget
  - Fix web support by @Ahmadre in [#91](https://github.com/LinXunFeng/flutter_scrollview_observer/pull/91)

## 1.21.1
- ObserverCore
  - improve the logic of `handleListObserve` and `handleGridObserve`.

## 1.21.0
- ObserverController
  - Add `onPrepareScrollToIndex` for `jumpTo` and `animateTo`.
- NestedScrollUtil
  - Add `jumpTo` and `animateTo` methods.

## 1.20.0
- ObserverController
  - Add `observeIntervalForScrolling` to set the minimum amount of time to wait for firing observe callback during scrolling.
- ObserverUtils
  - Improve the logic of `isDisplayingSliverInViewport` method.
- ScrollViewOnceObserveNotificationResult
  - Add `observeViewportResultModel`.
- ChatScrollObserver
  - Add `ChatScrollObserverRefIndexType`.
  - Add `refIndexType` to specify the role of `refItemIndex` and `refItemIndex`.
- Slivers
  - Add `SliverObserveContext`.
- ObserveDisplayingChildModelMixin
  - Add `visibleFraction` and `visibleMainAxisSize`.

## 1.19.1
- ListViewObserver
  - Support `SliverVariedExtentList` in [74](https://github.com/fluttercandies/flutter_scrollview_observer/issues/74).
- Chat Observer
  - Safely obtain the `constraints` of RenderSliver.
- ObserverController
  - Adapt to scenes where `CustomScrollView` specifies `center`.

## 1.19.0
- SliverViewObserver
  - Add `customOverlap` property.
- NestedScrollUtil
  - To better support `NestedScrollView`.
- ObserverCore
  - Improve the judgment logic of whether the sliver is visible.
- ObserverController
  - Adjust the controller to be modifiable.

## 1.18.2
- Chat Observer
  - Fix keeping position not working by @LinXunFeng in [#64](https://github.com/fluttercandies/flutter_scrollview_observer/issues/64)

## 1.18.1
- Add a check to determine whether the BuildContext is mounted by @LinXunFeng in [#62](https://github.com/fluttercandies/flutter_scrollview_observer/issues/62)

## 1.18.0
- ObserverController
  - Add some scrolling task notifications extending from `ObserverScrollNotification`.
  - The `jumpTo` method and `animateTo` method support `await`.
  - Add `isForbidObserveCallback` property.
  - Add `isForbidObserveViewportCallback` property.

## 1.17.0
- ObserverController
  - The parameter `isFixedHeight` in the `jumpTo` method and `animateTo` method supports GridView and supports ScrollView built by third-party package by @percival888 in [#52](https://github.com/fluttercandies/flutter_scrollview_observer/pull/52).

## 1.16.5
- ObserverWidget
  - Improve the processing logic of scroll notification when scrolling with the mouse wheel is not smooth by @qiangjindong in [#48](https://github.com/LinXunFeng/flutter_scrollview_observer/pull/48).
- Chat Observer
  - Update `isShrinkWrap` once during initialization by @LinXunFeng. [#47](https://github.com/LinXunFeng/flutter_scrollview_observer/issues/47)
- ObserverController
  - Fix unable to jump when sliver is too far away and has no any child by @LinXunFeng. [#45](https://github.com/LinXunFeng/flutter_scrollview_observer/issues/45)
  - Fix continuous page turning due to incorrect index by @LinXunFeng.

## 1.16.4
- Supplement missing type conversion adjustments.

## 1.16.3
- Observation Model
  - Add viewport property to observation model.
  - Correct the calculation logic of some values to adapt to the scene of multiple slivers.

## 1.16.2
- ObserverWidget
  - Adjust the conversion type of `viewport.offset` to `ScrollPosition` by @LiuDongCai in [#41](https://github.com/LinXunFeng/flutter_scrollview_observer/pull/41).
- ObserveDisplayingChildModelMixin
  - Adapt `displayPercentage` to scenes with SliverPersistentHeader by @percival888 in [#43](https://github.com/LinXunFeng/flutter_scrollview_observer/pull/43).
  - Refine the logic of `calculateDisplayPercentage` method by @LinXunFeng.

## 1.16.1
- Compatible with flutter 3.13.0

## 1.16.0
- ObserverController
  - `dispatchOnceObserve` method supports directly getting observation result.

## 1.15.0
- Slivers
  - Add `SliverObserveContextToBoxAdapter`.

## 1.14.2
- ObserverWidget
  - Safe to use context. [#35](https://github.com/LinXunFeng/flutter_scrollview_observer/issues/35).

## 1.14.1
- Chat Observer
  - Improve the logic of the conversion type.

## 1.14.0
- Chat Observer
  - Support for keeping position of generative messages (eg: ChatGPT)

## 1.13.2
- ObserverWidget 
  - Fix getting bad observation result on web. Thanks to @rmasarovic for the test in [#31](https://github.com/LinXunFeng/flutter_scrollview_observer/issues/31)

## 1.13.1
- ObserverCore
  - Fix no getting all child widgets those are displayed when there are separators in `ListView`. [#31](https://github.com/LinXunFeng/flutter_scrollview_observer/issues/31)
- ObserverUtils
  - Safely call `findRenderObject` method.

## 1.13.0
- ObserverUtils
  - The `calcAnchorTabIndex` method supports GridView.
- ObserverCore
  - Refine the logic of `handleListObserve` method and `handleGridObserve` method.

## 1.12.0
- ObserverWidget
  - Support custom observation object and observation logic.
  - Refine the logic for finding the first sliver in viewport.

## 1.11.0
- Chat Observer
  - Support inserting multiple messages at once.
- ObserverWidget
  - `GridViewObserver` is compatible with waterfall flow.
  - `SliverViewObserver` supports observation of viewport.

## 1.10.1
- ObserverController
  - fix: targetOffset calculate may be negative by @zeqinjie in [#21](https://github.com/LinXunFeng/flutter_scrollview_observer/pull/21).

## 1.10.0
- ObserverController
  - Improve `[_calculateTargetLayoutOffset]` logic.
  - The `jumpTo` method and `animateTo` method both add a parameter `[padding]`.
- ObserverIndexPositionModel
  - Add property `[padding]`.

## 1.9.2
- ObserverWidget
  - Catch the exception thrown by getting size.

## 1.9.1
- ObserverController
  - Modify offset calculation logic in method `[_calculateTargetLayoutOffset]`.

## 1.9.0
- ObserverWidget
  - Add property `[autoTriggerObserveTypes]` and property `[triggerOnObserveType]`.
- ObserverController
  - Method `[dispatchOnceObserve]` adds parameter `[isForce]`.

## 1.8.0
- Scrolling to the specified index location
  - Supports initializing the index position of the scrollView.
  - Deprecated `[clearIndexOffsetCache]`, please use `[clearScrollIndexCache]` instead.

## 1.7.0
- Chat Observer
  - Add the property `[fixedPositionOffset]`.
  - Deprecated `[ChatObserverClampinScrollPhysics]`, please use `[ChatObserverClampingScrollPhysics]` instead.

## 1.6.2
- Fix lib not working when `itemExtent` is set in `ListView`.

## 1.6.1
- Fix lib not working when `shrinkWrap` is `true` in scrollView.

## 1.6.0
- Chat Observer
  - Add `onHandlePositionCallback`.

## 1.5.1
- Fix scrollView being stuck when child widget get `[size]`.

## 1.5.0
- Chat Observer
  - Quickly implement the chat session page effect.
- Scrolling to the specified index location
  - Add the property `[cacheJumpIndexOffset]`.

## 1.4.0
- Scrolling to the specified index location
  - New `alignment` parameter in the `jumpTo` and `animateTo` methods.
  - Fixed a bug that caused scrolling to the first child to jitter when using `offset` parameter.

## 1.3.0
- Scrolling to the specified index location supports the `SliverPersistentHeader`.
- Add `ObserverUtils`
  - Method `calcPersistentHeaderExtent`: Calculate current extent of `RenderSliverPersistentHeader`.
  - Method `calcAnchorTabIndex`: Calculate the anchor tab index.

## 1.2.0
- The `jumpTo` and `animateTo` methods add an `isFixedHeight` parameter to optimize performance when the child widget is of fixed height
- Add the properties `[leadingMarginToViewport]` and `[trailingMarginToViewport]`
- Support mixing usage of `SliverList` and `SliverGrid`

## 1.1.0
- Supports scrolling to the specified index location

## 1.0.1
- Delete useless code

## 1.0.0

- Implements a way to use without sliver [BuildContext]
- Change [onObserve] to [onObserveAll], and add a new [onObserve] callback to listen for changes in the child widget display of the first sliver
- Add [ObserverController]

## 0.1.0

- Support `GridView`
- Support the horizontal

## 0.0.1

- Initial release
