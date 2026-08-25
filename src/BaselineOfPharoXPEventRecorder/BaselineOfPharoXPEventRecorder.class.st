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
		self defineEventRecorderPackagesOn: spec.
		self definePharoXPPackagesOn: spec.
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

	spec package: 'EventRecorder'.
	spec
		package: 'EventRecorder-Tests'
		with: [ spec requires: #( 'EventRecorder' ) ].
	spec
		package: 'EventRecorder-Server'
		with: [ spec requires: #( 'EventRecorder' ) ].
	spec
		package: 'EventRecorder-Server-Tests'
		with: [ spec requires: #( 'EventRecorder-Server' 'EventRecorder-Tests' ) ].

	"Optional packages retained from the original EventRecorder repository."
	spec
		package: 'EventRecorder-LegacyTools'
		with: [ spec requires: #( 'EventRecorder' ) ].
	spec
		package: 'EventRecorder-Fuel'
		with: [ spec requires: #( 'EventRecorder' ) ].
	spec
		package: 'EventRecorder-Fuel-Tests'
		with: [ spec requires: #( 'EventRecorder-Fuel' 'EventRecorder-Tests' ) ].
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
		group: 'Client' with: #( 'Core' 'Pharo-XP-EventRecorder-Client' );
		group: 'Server' with: #(
			'Client'
			'EventRecorder-Server'
			'Pharo-XP-EventRecorder-Server' );
		group: 'Dispatcher' with: #( 'Phex-Data-Dispatcher' );
		group: 'Tests' with: #(
			'EventRecorder-Tests'
			'EventRecorder-Fuel-Tests'
			'EventRecorder-Server-Tests'
			'Phex-Data-Dispatcher-Tests'
			'Pharo-XP-EventRecorder-Client-Tests'
			'Pharo-XP-EventRecorder-Server-Tests' );
		group: 'Optional' with: #(
			'EventRecorder-LegacyTools'
			'EventRecorder-Fuel'
			'EventRecorder-Fuel-Tests'
			'EventRecorder-Inspector'
			'EventRecorder-UI'
			'EventRecorder-UI-Tests' );
		group: 'default' with: #( 'Server' );
		group: 'all' with: #( 'Server' 'Dispatcher' 'Tests' 'Optional' )
]

{ #category : 'baselines' }
BaselineOfPharoXPEventRecorder >> definePharoXPPackagesOn: spec [

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
