## 1.7.0
- Chat Observer
  - Add the property `[fixedPositionOffset]`.
  - Deprecated [ChatObserverClampinScrollPhysics], please use [ChatObserverClampingScrollPhysics] instead.

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
  - New `alignment` paramter in the `jumpTo` and `animateTo` methods.
  - Fixed a bug that caused scrolling to the first child to jitter when using `offset` paramter.

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
