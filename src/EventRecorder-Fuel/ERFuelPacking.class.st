"
I serialize or materialize objects using FUEL framework. Create instance of me calling GTEventPacking fuel.
"
Class {
	#name : #ERFuelPacking,
	#superclass : #EREventPacking,
	#instVars : [
		'migrations'
	],
	#category : #'EventRecorder-Fuel'
}

{ #category : #adding }
ERFuelPacking >> addMigration: oneArgBlock [ 
	^ self migrations addLast: oneArgBlock
]

{ #category : #initialization }
ERFuelPacking >> initializeMaterializer: aFLMaterializer [ 
	self migrations do: [ :eachMigration | eachMigration value: aFLMaterializer ]
]

{ #category : #initialization }
ERFuelPacking >> initializeMigrations [
	| pragmas |
	pragmas := Pragma allNamed: #fuelMaterializerMigration in: self class.
	migrations := pragmas
		collect: [ :eachPragma | self perform: eachPragma methodSelector ]
		as: OrderedCollection
]

{ #category : #private }
ERFuelPacking >> materialize: aByteArray [
	| materializer stream gzstream materialization |
	stream := aByteArray asByteArray readStream. 
	gzstream := GZipReadStream on: stream.
	materializer := (FLMaterializer respondsTo: #newDefault)
		ifTrue: [ FLMaterializer newDefault ]
		ifFalse: [ FLMaterializer new ].
	self initializeMaterializer: materializer.
	materialization := (materializer respondsTo: #materializeFrom:)
		ifTrue: [ materializer materializeFrom: gzstream ]
		ifFalse: [
			materializer onStream: gzstream.
			materializer materialize ].
	gzstream close.
	stream close.
	^ (materialization respondsTo: #root)
		ifTrue: [ materialization root ]
		ifFalse: [ materialization ]
]

{ #category : #accessing }
ERFuelPacking >> migrations [
	migrations ifNil: [ self initializeMigrations ].
	^ migrations
]

{ #category : #accessing }
ERFuelPacking >> migrations: aCollectionOrNil [
	migrations := aCollectionOrNil
]

{ #category : #private }
ERFuelPacking >> serialize: anObject [
	| serializer stream gzstream |
	stream := ByteArray new writeStream binary. 
	gzstream := GZipWriteStream on: stream.
	serializer := (FLSerializer respondsTo: #newDefault)
		ifTrue: [ FLSerializer newDefault ]
		ifFalse: [ FLSerializer new ].
	serializer at: #recorderVersion putAdditionalObject: self version.
	(serializer respondsTo: #stream:)
		ifTrue: [
			serializer stream: gzstream.
			serializer serialize: anObject ]
		ifFalse: [
			serializer object: anObject.
			serializer onStream: gzstream.
			serializer serialize ].
	gzstream close.
	stream close.
	^ stream contents.
]

{ #category : #accessing }
ERFuelPacking >> technologyName [
	^ 'fuel'
]
