"
I consolidate PX collectors only when all routing metadata matches.
Collectors from different experiments, participants, tasks, categories, or
endpoints must never be merged.
"
Class {
	#name : #PXEventConsolidate,
	#superclass : #EREventConsolidate,
	#category : #'Pharo-XP-EventRecorder-Client'
}

{ #category : #private }
PXEventConsolidate >> consolidationKeyFor: aCollector [

	^ {
		aCollector url.
		aCollector category.
		aCollector experienceId.
		aCollector participantUUID.
		aCollector taskOrSurveyId }
]

{ #category : #'accessing - computed' }
PXEventConsolidate >> consolidated [

	| consolidatedCollectors |
	consolidatedCollectors := OrderedDictionary new.
	collectors do: [ :eachCollector |
		| targetCollector |
		targetCollector := consolidatedCollectors
			at: (self consolidationKeyFor: eachCollector)
			ifAbsentPut: [ eachCollector ].
		targetCollector == eachCollector ifFalse: [
			eachCollector bundle do: [ :eachEvent |
				targetCollector add: eachEvent ] ] ].
	^ consolidatedCollectors values asArray
]
