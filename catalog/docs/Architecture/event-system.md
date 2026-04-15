# Event system architecture

```plantuml
package "Base web-socket handling" as WSPackage {
  () "WS" as WebSocket
  component [WebSocket transformer] as WebSocketTransformer

  WebSocket .right.> WebSocketTransformer : Transforms events to generalized format
}

package "Base firebase handling" as FirebasePackage {
  () "Firebase" as Firebase
  component [Firebase transformer] as FirebaseTransformer
  Firebase .right.> FirebaseTransformer : Transforms firebase notifications to generalized format
}

component EventBus {
  portin fire
  portout listen
}

WSPackage --> fire : Fires web-socket events
FirebasePackage --> fire : Fires firebase events

component ActionEventsTrafficListener
ActionEventsTrafficListener -up-> listen

component ActionEventsTransformer 
ActionEventsTrafficListener  --> ActionEventsTransformer
ActionEventsTrafficListener  --> fire : fires transformed event
```