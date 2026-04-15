# Event bus

## Event bus overview
![Event bus preview](https://raw.githubusercontent.com/marcojakob/dart-event-bus/master/doc/event-bus.png)

Mostly `EventBus` pattern is used in `MVC` or `MVP` patterns to decouple controllers from each other and let them be independend but have communication. In our application this pattern not used widely but still it's a big part of application

## Our implementation

We have our own implemented interface for interraction with event bus with some extensions on library [event_bus](https://pub.dev/packages/event_bus).

In out case we have `TrafficHandler` class as an extension on event bus. It serves as part of chain of responsibility. By this thing we can register handler on some type of events and have handlers chain

On the other hand we have usecases which are responsible for sending event to event bus.

## Where it used

Basically event bus is used to notify system that some events are happened. For example notifications or chat system.

### Notifications

Whenever notification from any service comes to application it goes through parsing process and after that fires in the bus. 

Because of it whole application knows that we got new notification and responsible classes can perform some actions.

### Chat

On the other side any streamable events can be implemented throught events in bus. As an example is chat with support service.

Because we're getting updates of chat topics through web-socket we need somehow notify our application layer that we got new message. For this case we're also sending event to the event bus that we've received new message with message's data