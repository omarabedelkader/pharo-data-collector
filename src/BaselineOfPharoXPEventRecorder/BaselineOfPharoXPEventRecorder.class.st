Class {
	#name : 'BaselineOfPharoXPEventRecorder',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPharoXPEventRecorder',
	#package : 'BaselineOfPharoXPEventRecorder'
}

{ #category : 'baselines' }
BaselineOfPharoXPEventRecorder >> baseline: spec [

	<baseline>
	spec for: #common do: [
		"The old (cleaned) version"
		self defineEventRecorderPackagesOn: spec.
		
		"Some ad-hoc extensions"
		self definePharoXPPackagesOn: spec.

		"a kind of gate and port redirection"
		self defineDispatcherPackagesOn: spec.
		
		self defineGroupsOn: spec ]
]

{ #category : 'baselines' }
BaselineOfPharoXPEventRecorder >> defineDispatcherPackagesOn: spec [

	spec package: 'Phex-Data-Dispatcher'.
	spec
		package: 'Phex-Data-Dispatcher-Tests'
		with: [ spec requires: #(
			'Phex-Data-Dispatcher'
			'EventRecorder-Tests' ) ]
]

{ #category : 'baselines' }
BaselineOfPharoXPEventRecorder >> defineEventRecorderPackagesOn: spec [

	spec package: 'EventRecorder';
		package: 'EventRecorder-Tests'
		with: [ spec requires: #( 'EventRecorder' ) ].
	spec
		package: 'EventRecorder-Server'
		with: [ spec requires: #( 'EventRecorder' ) ];
		package: 'EventRecorder-Server-Tests'
		with: [ spec requires: #( 'EventRecorder-Server' 'EventRecorder-Tests' ) ].


	"Optional packages retained from the original EventRecorder repository."
	spec
		package: 'EventRecorder-LegacyTools'
		with: [ spec requires: #( 'EventRecorder' ) ].
	spec
		package: 'EventRecorder-Inspector'
		with: [ spec requires: #( 'EventRecorder-LegacyTools' ) ].
	spec
		package: 'EventRecorder-UI'
		with: [ spec requires: #( 'EventRecorder' ) ].
	spec
		package: 'EventRecorder-UI-Tests'
		with: [ spec requires: #( 'EventRecorder-UI' ) ]
]

{ #category : 'baselines' }
BaselineOfPharoXPEventRecorder >> defineGroupsOn: spec [

	spec
		group: 'Core' with: #( 'EventRecorder' );
		group: 'Server' with: #( 'Core' 'EventRecorder-Server');
		group: 'Tests' with: #(
			'EventRecorder-Tests'
			'EventRecorder-Server-Tests');
	
		
		"Optional to offer a kind of redirect."
		group: 'Dispatcher' with: #( 'Phex-Data-Dispatcher' 'Phex-Data-Dispatcher-Tests');
		
		"Optional: Some extensions to support different organisation on disc 
		with the start of descriptions to do it. "
		group: 'Phex' with: #(
			'Pharo-XP-EventRecorder-Client'
			'Pharo-XP-EventRecorder-Server' 
			'Pharo-XP-EventRecorder-Client-Tests'
			'Pharo-XP-EventRecorder-Server-Tests' );
		
		group: 'Optional' with: #(
			'EventRecorder-LegacyTools'
			'EventRecorder-Inspector'
			'EventRecorder-UI'
			'EventRecorder-UI-Tests' );
		group: 'default' with: #( 'Server' 'Tests');
		
		group: 'all' with: #( 'Server' 'Dispatcher' 'Phex' 'Tests' 'Optional' )
]

{ #category : 'baselines' }
BaselineOfPharoXPEventRecorder >> definePharoXPPackagesOn: spec [
	
	" Pharo-XP is a kind of extensions that builds a layer 
	instead of pushing some changes to provide a more extensible core."
	
	spec
		package: 'Pharo-XP-EventRecorder-Client'
		with: [ spec requires: #( 'EventRecorder' ) ].
	spec
		package: 'Pharo-XP-EventRecorder-Server'
		with: [ spec requires: #(
			'Pharo-XP-EventRecorder-Client'
			'EventRecorder-Server' ) ].
	spec
		package: 'Pharo-XP-EventRecorder-Client-Tests'
		with: [ spec requires: #(
			'Pharo-XP-EventRecorder-Client'
			'EventRecorder-Tests' ) ].
	spec
		package: 'Pharo-XP-EventRecorder-Server-Tests'
		with: [ spec requires: #(
			'Pharo-XP-EventRecorder-Server'
			'Pharo-XP-EventRecorder-Client-Tests'
			'EventRecorder-Server-Tests' ) ]
]
