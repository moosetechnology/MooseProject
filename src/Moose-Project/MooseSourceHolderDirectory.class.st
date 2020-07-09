"
A MooseSourceHolderDirectory is a specific holder for sources contained in a directory

Instance Variables
	importDirectory:		<Object>

importDirectory
	- xxxxx

"
Class {
	#name : #MooseSourceHolderDirectory,
	#superclass : #MooseSourceHolder,
	#instVars : [
		'importDirectory',
		'latestVersionDate',
		'shouldPersistSources'
	],
	#category : #'Moose-Project'
}

{ #category : #'instance creation' }
MooseSourceHolderDirectory class >> on: aDirectory [
	^ self new
		importDirectory: aDirectory;
		yourself
]

{ #category : #adding }
MooseSourceHolderDirectory >> addSource: aSource [
	self assert: aSource isDirectorySource description: 'I am a source holder directory so i only accept directory source'.
	self latestVersionDate: aSource date.
	self importDirectory: aSource directory.
]

{ #category : #versions }
MooseSourceHolderDirectory >> closestDateTo: aDate [ 
	^ self latestVersionDate
]

{ #category : #accessing }
MooseSourceHolderDirectory >> importDirectory [
	^ importDirectory
]

{ #category : #accessing }
MooseSourceHolderDirectory >> importDirectory: anObject [
	importDirectory := anObject asFileReference
]

{ #category : #initialization }
MooseSourceHolderDirectory >> initialize [
	super initialize.
	self shouldPersistSources: true.
]

{ #category : #versions }
MooseSourceHolderDirectory >> latestSources [
	^ self sourcesAtDate: self latestVersionDate
]

{ #category : #accessing }
MooseSourceHolderDirectory >> latestVersionDate [
	^ latestVersionDate ifNil: [DateAndTime now]
]

{ #category : #accessing }
MooseSourceHolderDirectory >> latestVersionDate: aDate [
	latestVersionDate := aDate
]

{ #category : #testing }
MooseSourceHolderDirectory >> requireSourcePersistance [
	^ shouldPersistSources
]

{ #category : #accessing }
MooseSourceHolderDirectory >> shouldPersistSources [
	^ shouldPersistSources
]

{ #category : #accessing }
MooseSourceHolderDirectory >> shouldPersistSources: anObject [
	shouldPersistSources := anObject
]

{ #category : #versions }
MooseSourceHolderDirectory >> sourcesAtDate: aDate [
	^ MooseDirectorySource date: aDate directory: self importDirectory
]
