"
I simplify the process of downloading and extracting of recorded data.

You likely want to use #ensureLocalDirectory that downloads and extracts server data or #unpackAll if you want to load all data into memory.


Here is the code of the UI to open the settings

```
openSettingsBrowser
	| settingsBrowser window node nodePath |
	settingsBrowser := SettingBrowser new 
		changePackageSet: { PackageOrganizer default packageNamed: 'EventRecorder' };
		yourself.
	window := settingsBrowser open.
	settingsBrowser expandAll.
```	

### Downloading Data
When the server let you access to the stored data you can use the EREventTool to download the data.
The collected data on the server are stored using a standard Linux file system.
The EREventTool class to download all collected data by executing:

```	
	EREventTool default ensureDownloadedData.
```

It is downloaded to your working directory (next to your Pharo image). Ideally you could extract it using `EREventTool default ensureExtractedData`, but the current Pharo version does not support ZIP signature that is used for large files. But you can do it manually using standard tools of your system. 
	
### Data Structure

For the ERRecorder core, the data should be structured per category and per month (to be confirmed). The category is defined by the client side Let us say that your category is called `myCoolTool` and you have been collecting data since November 2016 to January 2017. Then you will find out the following directory structure:
	
	./imageDirectory/var/..../myCoolTool
		/201611/  - data collected during November 2016
		/201612/  - data collected during Dicember 2016
		/201701/  - data collected during January 2017

	Each file is a serialized `EREventAnnouncement` object. The object is a data container of meta data and of collected events.

### Analysis
	
We recomend you to remove all data that you are not interested in and start your analysis. To load all data available in the directory executing:
	
```	
	EREventTool default unpackAll inspect.
```

It returns an association `unpackedData -> exceptions`. The key `unpackedData` includes all your data, the value `exceptions` all catched exception that happened while loading the data. You can thus load all correct data and check all errors.

"
Class {
	#name : 'EREventTool',
	#superclass : 'Object',
	#category : 'EventRecorder-LegacyTools',
	#package : 'EventRecorder-LegacyTools'
}

{ #category : 'accessing' }
EREventTool class >> default [
	^ self new
]

{ #category : 'configuration' }
EREventTool >> defaultDownloadDirectory [
	^ FileSystem disk workingDirectory
]

{ #category : 'configuration' }
EREventTool >> defaultDownloadFilename [
	^ self defaultDownloadDirectory / 'gt-events.zip'
]

{ #category : 'configuration' }
EREventTool >> defaultEventsDirectory [
	^ self defaultDownloadDirectory / 'gt' / 'events'
]

{ #category : 'private' }
EREventTool >> defaultUrl [
	^ 'http://gc.dcc.uchile.cl/gt-events.zip'
]

{ #category : 'api' }
EREventTool >> download [
	"self default download"
 	UIManager default informUserDuring: [ :bar |
		bar label: 'Downloading Event Data...'.
		[ ZnClient new
			url: self defaultUrl;
			signalProgress: true;
			downloadTo: self defaultDownloadFilename ]
		on: HTTPProgress 
		do: [ :progress |
			progress isEmpty ifFalse: [ 
				bar current: progress percentage.
				progress total ifNotNil: [ :aTotalNumber | | humanReadable |
					humanReadable := self printHumanReadableSize: aTotalNumber.
					bar label: 'Downloading ', humanReadable, ' of Event Data... ' ] ].
			progress resume ] 
	]
]

{ #category : 'api' }
EREventTool >> ensureDownloadedData [
	self defaultDownloadFilename exists ifFalse: [ self download ]
]

{ #category : 'api' }
EREventTool >> ensureExtractedData [
	self defaultEventsDirectory exists ifFalse: [ self extract ]
]

{ #category : 'api' }
EREventTool >> ensureLocalDirectory [
	"self default ensureLocalDirectory"
	self 
		ensureDownloadedData;
		ensureExtractedData
]

{ #category : 'api' }
EREventTool >> extract [
	(ZipArchive new readFrom: self defaultDownloadFilename) extractAllTo: FileLocator workingDirectory.
]

{ #category : 'printing' }
EREventTool >> printHumanReadableSize: aTotalNumber [
	| humanReadable length unit |
	length := ((aTotalNumber decimalDigitLength / 3) truncated) - 1 max: 0.
	humanReadable := (aTotalNumber / (1024 raisedTo: (length min: 3))) rounded.
	length = 0 ifTrue: [ unit := 'bytes' ].
	length = 1 ifTrue: [ unit := 'KB' ].
	length = 2 ifTrue: [ unit := 'MB' ].
	length = 3 ifTrue: [ unit := 'GB' ].
	^ humanReadable printString, ' ', unit
]

{ #category : 'api' }
EREventTool >> unpackAll [
	"self default unpackAll inspect"
	self ensureLocalDirectory.
	^ EREventUnpacking default safeUnpackDirectory: self defaultEventsDirectory.
]

{ #category : 'api' }
EREventTool >> unpackAll: aFileReference [
	"self default unpackAll: './gt/events' asFileReference.
	self default unpackAll: './gt/events/roassal2Examples' asFileReference.
	" 
	self ensureLocalDirectory.
	^ EREventUnpacking default safeUnpackDirectory: aFileReference.
]
