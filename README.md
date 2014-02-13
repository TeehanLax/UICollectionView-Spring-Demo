UICollectionView-Spring-Demo
============================
A demonstration of UICollectionView and UIKit Dynamics. Uses tiling in order to maintain high-performance even with ten thousand cells.

## Demo
![Animation](http://f.cl.ly/items/161u2F0U383G0f0c3h3j/animation.gif)

## Usage
To use this in your project, just add the `TLSpringFlowLayout` classes. Then create a UICollectionView (either with code or in a Storyboard). Set the UICollectionView's Flow Layout object to `TLSpringFlowLayout`.

## Extra Goodies
If you setup your collection with code, you can set the `scrollResistanceFactor` property. This property increases the *bounciness* of the collection items as they scroll. 

You can also retrieve the `dynamicAnimator` property (read-only) if necessary.

## License
MIT License. Copyright (c) 2013 Teehan+Lax. See the LICENSE file for more information.

Created by Teehan+Lax. Updated by Sam Spencer on February 8, 2014.
