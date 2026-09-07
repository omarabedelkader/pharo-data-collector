Class {
	#name : 'BaselineOfEventRecorder',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfEventRecorder',
	#package : 'BaselineOfEventRecorder'
}

{ #category : 'baselines' }
BaselineOfEventRecorder >> baseline: spec [
	<baseline>
	
	spec for: #common do: [
		self defineEventRecorderPackagesOn: spec.
		self defineGroupsOn: spec ]
]

{ #category : 'baselines' }
BaselineOfEventRecorder >> defineEventRecorderPackagesOn: spec [

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
BaselineOfEventRecorder >> defineGroupsOn: spec [

	spec
		group: 'Core' with: #( 'EventRecorder' );
		group: 'Client' with: #( 'Core' );
		group: 'Server' with: #( 'Client' 'EventRecorder-Server' );
		group: 'Tests' with: #(
			'EventRecorder-Tests'
			'EventRecorder-Fuel-Tests'
			'EventRecorder-Server-Tests' );
		group: 'Optional' with: #(
			'EventRecorder-LegacyTools'
			'EventRecorder-Fuel'
			'EventRecorder-Fuel-Tests'
			'EventRecorder-Inspector'
			'EventRecorder-UI'
			'EventRecorder-UI-Tests' );
		group: 'default' with: #( 'Server' );
		group: 'all' with: #( 'Server' 'Tests' 'Optional' )
]
