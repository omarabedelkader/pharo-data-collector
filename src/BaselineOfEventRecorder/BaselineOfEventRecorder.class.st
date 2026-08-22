Class {
	#name : #BaselineOfEventRecorder,
	#superclass : #BaselineOf,
	#category : #BaselineOfEventRecorder
}

{ #category : #baselines }
BaselineOfEventRecorder >> baseline: spec [

	<baseline>
	spec for: #common do: [
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
			package: 'EventRecorder-Help'
			with: [ spec requires: #( 'EventRecorder' ) ].
		spec
			package: 'EventRecorder-UI'
			with: [ spec requires: #( 'EventRecorder' ) ].
		spec
			package: 'EventRecorder-UI-Tests'
			with: [ spec requires: #( 'EventRecorder-UI' ) ].

		spec
			group: 'Core' with: #( 'EventRecorder' );
			group: 'Server' with: #( 'Core' 'EventRecorder-Server' );
			group: 'Tests' with: #( 'EventRecorder-Tests' 'EventRecorder-Server-Tests' );
			group: 'Optional' with: #(
				'EventRecorder-LegacyTools'
				'EventRecorder-Fuel'
				'EventRecorder-Fuel-Tests'
				'EventRecorder-Inspector'
				'EventRecorder-Help'
				'EventRecorder-UI'
				'EventRecorder-UI-Tests' );
			group: 'default' with: #( 'Core' ) ]
]
