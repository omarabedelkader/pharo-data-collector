"
I consolidate EREventCollector instances that target the same endpoint and
category. Consolidation reduces the number of bundles without mixing data
that belongs to different destinations.
"
Class {
	#name : 'EREventConsolidate',
	#superclass : 'Object',
	#instVars : [
		'collectors'
	],
	#category : 'EventRecorder-Support',
	#package : 'EventRecorder',
	#tag : 'Support'
}

{ #category : 'accessing' }
EREventConsolidate >> collectors: aCollection [

	collectors := aCollection
]

{ #category : 'accessing - computed' }
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

{ #category : 'private' }
EREventConsolidate >> consolidationKeyFor: aCollector [
	"Returns the keys on which data can be merged together. 
	Here spread data can be regrouped (consolidated) based either on the url or the category."
	^ {
		aCollector url.
		aCollector category }
]
