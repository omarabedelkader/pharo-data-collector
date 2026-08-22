"
I consolidate EREventCollector instances that target the same endpoint and
category. Consolidation reduces the number of bundles without mixing data
that belongs to different destinations.
"
Class {
	#name : #EREventConsolidate,
	#superclass : #Object,
	#instVars : [
		'collectors'
	],
	#category : #'EventRecorder-Support'
}

{ #category : #private }
EREventConsolidate >> consolidationKeyFor: aCollector [

	^ {
		aCollector url.
		aCollector category }
]

{ #category : #'accessing - computed' }
EREventConsolidate >> consolidated [

	| consolidatedCollectors |
	consolidatedCollectors := OrderedDictionary new.
	collectors do: [ :eachCollector |
		| targetCollector |
		targetCollector := consolidatedCollectors
			at: (self consolidationKeyFor: eachCollector)
			ifAbsentPut: [
				EREventCollector new
					url: eachCollector url;
					category: eachCollector category;
					yourself ].
		eachCollector bundle do: [ :eachEvent |
			targetCollector add: eachEvent ] ].
	^ consolidatedCollectors values asArray
]

{ #category : #accessing }
EREventConsolidate >> collectors: aCollection [

	collectors := aCollection
]
