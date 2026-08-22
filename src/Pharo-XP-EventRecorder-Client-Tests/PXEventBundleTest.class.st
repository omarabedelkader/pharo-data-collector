Class {
	#name : #PXEventBundleTest,
	#superclass : #EREventBundleTest,
	#category : #'Pharo-XP-EventRecorder-Client-Tests'
}

{ #category : #tests }
PXEventBundleTest >> testNewMultiBundle [
	self assert: PXEventBundle new newMultiBundle class equals: PXEventMultiBundle
]
