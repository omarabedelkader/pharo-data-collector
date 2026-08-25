"
I know how to start and stop default Event Recorder server.
Check my two start and stop methods on the class side.
"
Class {
	#name : 'EREventRecorderServer',
	#superclass : 'Object',
	#category : 'EventRecorder-Server',
	#package : 'EventRecorder-Server'
}

{ #category : 'accessing' }
EREventRecorderServer class >> start [
	"self start"
	(ZnServer startDefaultOn: 8080)
		route: 'Default EventRecorder-Server';
		delegate: EREventRecorderDelegate new.
]

{ #category : 'accessing' }
EREventRecorderServer class >> stop [
	"self stop"
	ZnServer stopDefault
]

{ #category : 'see class side' }
EREventRecorderServer >> seeClassSide [
]
