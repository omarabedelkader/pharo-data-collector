Class {
	#name : 'ERFuelPackingTest',
	#superclass : 'EREventPackingTest',
	#category : 'EventRecorder-Fuel-Tests',
	#package : 'EventRecorder-Fuel-Tests'
}

{ #category : 'accessing' }
ERFuelPackingTest >> packingClass [
	^ ERFuelPacking
]

{ #category : 'private' }
ERFuelPackingTest >> removeMigrationFixtureClass [
	(Smalltalk globals includesKey: #ERFuelPackingMigrationFixture)
		ifTrue: [ (Smalltalk globals at: #ERFuelPackingMigrationFixture) removeFromSystem ]
]

{ #category : 'tests' }
ERFuelPackingTest >> testMigration [
	| oldClass oldObject |
	self removeMigrationFixtureClass.
	[
		oldClass := (Object << #ERFuelPackingMigrationFixture) install.
		oldObject := oldClass new.
		collector := EREventCollector new.
		collector add: oldObject.
		bundle := packing pack: collector.
		oldClass removeFromSystem.
		announcement := packing unpack: bundle data.
		self should: [ announcement unpackedData ] raise: FLClassNotFound ]
		ensure: [ self removeMigrationFixtureClass ]
]

{ #category : 'tests' }
ERFuelPackingTest >> testMigration2 [
	| oldClass oldClassName oldObject |
	self removeMigrationFixtureClass.
	[
		oldClass := (Object << #ERFuelPackingMigrationFixture) install.
		oldClassName := oldClass name asSymbol.
		oldObject := oldClass new.
		collector := EREventCollector new.
		collector add: oldObject.
		bundle := packing pack: collector.
		oldClass removeFromSystem.
		packing addMigration: [ :aMaterializer |
			aMaterializer migrateClassNamed: oldClassName toClass: ERDummyEvent ].
		announcement := packing unpack: bundle data.
		announcement migrationRules: packing migrations.
		unpackedData := announcement unpackedData.
		self assert: unpackedData isCollection.
		self assert: unpackedData size equals: 1.
		self assert: unpackedData anyOne class equals: ERDummyEvent ]
		ensure: [ self removeMigrationFixtureClass ]
]
