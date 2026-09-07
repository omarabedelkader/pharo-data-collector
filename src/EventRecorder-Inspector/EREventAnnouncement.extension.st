Extension { #name : 'EREventAnnouncement' }

{ #category : '*EventRecorder-Inspector' }
EREventAnnouncement >> inspectData: aBuilder [
	<inspectorPresentationOrder: 0 title: 'Data'>

	
	^ aBuilder newCode
		addStyle: 'stCode';
		withoutSyntaxHighlight;
		text: self unpackedData displayString;
		yourself.
	
]

{ #category : '*EventRecorder-Inspector' }
EREventAnnouncement >> inspectDataContext: aContext [
	
	^ aContext active: self data isNotNil
]

{ #category : '*EventRecorder-Inspector' }
EREventAnnouncement >> inspectionContents: aBuilder [
	<inspectorPresentation: 10 title: 'Contents'>

	| data |
	data := self at: #data ifAbsent: [ '' ].
	data class = ByteArray 
		ifTrue: [ self at: #data put: (EREventUnpacking default unpack: data) first].
	"Super ugly when we browse we modifiy the object" 
	^ aBuilder newTable
		addStyle: 'stList';
		addColumn: (SpStringTableColumn new
			title: 'Key';
			evaluated: [ :each | each key ];
			formatted: [ :key | StObjectPrinter asTruncatedTextFrom: key ];
			beSortable);
		addColumn: (SpStringTableColumn new
			title: 'Value';
			evaluated: [ :each | each value ];
			formatted: [ :value |
			   StObjectPrinter asTruncatedTextFrom: value ];
			beSortable);
		items: (self associations collect: [ :e | 
			StInspectorAssociationNode hostObject: e ]);
		yourself
]
