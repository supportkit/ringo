Ringo
============

Add one-way live video, two-way audio chat, screen sharing and annotations to your iOS app in minutes.
Use this to create an experience similar to Amazon Mayday within your app.

This project was built as part of a Hackathon at Radialpoint (http://radialpoint.com) in Montreal. We thought
that the experience created by Mayday was groovy and wanted to see if we could build an SDK that encourages
more apps to adopt its experience.

See our demo video and learn more at http://radialpoint.github.io/ringo

Currently the code is highly experimental but shouldn't be too hard for you to clean up
and add into your app if you love the great end-user experience it can provide.

Requirements
============

iOS SDK:
 * AFNetworking
 * SocketIO
 * SocketRocket
 * OpenTok - You *must* sign up for an API key (a free trial is available) at http://opentok.com

Agent Backend:
 * nodejs
 * mongodb (Mongo HQ works just fine)
 * SocketIO

Adding Ringo to your iOS App
===========

### Project configuration

1. Copy the "Ringo" folder from the distribution above into your XCode project.
2. Add AFNetworking, SocketIO and SocketRocket to your project if you haven't already.
3. Download and configure the OpenTok iOS SDK from http://tokbox.com/opentok/libraries/client/ios/ - *Carefully* follow the instructions on that page to set up OpenTok, it's a little tricky
4. In your project's build settings, set the `Architectures` setting to `$(ARCHS_STANDARD_32_BIT)`

### Code Changes

1. In the file `RGOVideoViewController.m` replace `kApiKey` and `kApiEndpoint` with your OpenTok API key and the URL you deployed the Ringo backend to.

2. In your app, `#import "Ringo.h"` and simply call `[Ringo showTime]` in your event handler should kick off the video session with a support agent.

Take a quick look at the AwesomeApp sample in this source tree if you have any questions.

Deploying the Agent Backend
===========


Limitations
===========

* The backend currently supports only one connection at a time. We're toying with multiple session support and queueing but would love some help!
* Apps must be compiled for 32 bit ARM (can't be built specifically for iPhone 5S) - this is purely an OpenTok limitation.
* It's buggy, but fun. Enjoy!


Stay groovy, brothers & sisters!
