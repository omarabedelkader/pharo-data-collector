"
I consolidate PX collectors only when all routing metadata matches.
Collectors from different experiments, participants, tasks, categories, or
endpoints must never be merged.
"
Class {
	#name : 'PXEventConsolidate',
	#superclass : 'EREventConsolidate',
	#category : 'Pharo-XP-EventRecorder-Client',
	#package : 'Pharo-XP-EventRecorder-Client'
}

{ #category : 'accessing - computed' }
PXEventConsolidate >> consolidated [

	| consolidatedCollectors |
	consolidatedCollectors := OrderedDictionary new.
	collectors do: [ :eachCollector |
		| targetCollector |
		targetCollector := consolidatedCollectors
			at: (self consolidationKeyFor: eachCollector)
			ifAbsentPut: [ eachCollector ].
		targetCollector == eachCollector ifFalse: [
			eachCollector flushAndCollectedData do: [ :eachEvent |
				targetCollector add: eachEvent ] ] ].
	^ consolidatedCollectors values asArray
]

{ #category : 'private' }
PXEventConsolidate >> consolidationKeyFor: aCollector [
	"Returns the keys on which data can be merged together. 
	Here spread data can be regrouped (consolidated) based either on the url or the category, experienceId,...."
	^ {
		aCollector url.
		aCollector category.
		aCollector experienceId.
		aCollector participantUUID.
		aCollector taskOrSurveyId }
]
