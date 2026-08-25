"
I'm a little framework to collect data from Pharo and publish it on server.

This framework has been developed by the GT team (probably T. Girba, A. Chis and others). Since this is a cool framework,I decided to invest in it and repackage it to avoid to have everything in a single package.

The vision is to have several packages.

EventRecorder
EventRecorderInspector
EventRecorderFuel
EventRecorderSTON
EventRecorderServer (should be migrated from SmalltalkHub -- See below)
EventRecorderHelp
and eventually adding tests

http://smalltalkhub.com/#!/~Moose/GToolkit repository, package GT-EventRecorder-Server, or load it using the following configuration:

Gofer it
	smalltalkhubUser: #Moose project: #GToolkit;
	configurationOf: #GTEventRecorderServer;
	loadStable.
"
Class {
	#name : 'EREventRecorderHelp',
	#superclass : 'AnObsoleteCustomHelp',
	#category : 'EventRecorder-Help',
	#package : 'EventRecorder-Help'
}

{ #category : 'accessing' }
EREventRecorderHelp class >> bookDescription [
	^ 'Here, we describe GT Event Recorder, a moldable infrastructure, that allows to capture and store events that are specific to different tools. It is composed of a client and a server that we describe in the following sections. The last section describes basic analysis support.'
]

{ #category : 'accessing' }
EREventRecorderHelp class >> bookName [
	^ 'GT Event Recorder'
]

{ #category : 'pages' }
EREventRecorderHelp class >> introduction [
	^HelpTopic 
		title: 'Introduction'
		contents:	
	'	GT Event Recorder is a moldable infrastructure that allows to capture custom made events that are specific to different tools. The semantics of collected events belongs to tools and developers who use GT Event Recorder. 
	
	Essentially, GT Event Recorder provides an infrastructure that allows researchers and tool builders to collect data easily. That is what makes it interesting.
	
	GT Event Recorder is composed of a client and a server that we describe in the following sections.' 
]

{ #category : 'accessing' }
EREventRecorderHelp class >> pages [
	^ #(introduction client server analysis)
]

{ #category : 'pages' }
EREventRecorderHelp class >> server [
	^HelpTopic 
		title: 'Server'
		contents:	
	'	The server is not included in the standard Pharo image. You can find it in http://smalltalkhub.com/#!/~Moose/GToolkit repository, package GT-EventRecorder-Server, or load it using the following configuration:
	
	Gofer it
		smalltalkhubUser: #Moose project: #GToolkit;
		configurationOf: #GTEventRecorderServer;
		loadStable.
	
	The server uses standard Zinc Server (ZnServer class) and you can start it by executing:
	
	GTEventRecorderServer start.
	
	By default, it runs on port 8080. If you need to run it with other services, check GTEventRecorderDelegate class.
	
	You can stop the server using: 
	
	GTEventRecorderServer stop.
	
	The standard server is executed on http://gc.dcc.uchile.cl:8080. 
	
	The following section describes the data storage and data analysis.
	' 
]
