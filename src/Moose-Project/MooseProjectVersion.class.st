"
A MooseProjectVersion is a dated version for a project. It makes easy to get MooseModel and store on any support the MSE.

Instance Variables
	date:		<Object>

date
	- xxxxx

"
Class {
	#name : #MooseProjectVersion,
	#superclass : #Object,
	#instVars : [
		'date',
		'mooseModel',
		'mooseProject',
		'modelClass',
		'mooseSource',
		'versionName'
	],
	#category : #'Moose-Project'
}

{ #category : #comparing }
MooseProjectVersion >> <= anotherVersion [
	^ self date <= anotherVersion date
]

{ #category : #comparing }
MooseProjectVersion >> = anObject [
	^ self species = anObject species and: [ self date = anObject date and: [ self modelClass = anObject modelClass ] ]
]

{ #category : #accessing }
MooseProjectVersion >> date [
	^ date
]

{ #category : #accessing }
MooseProjectVersion >> date: anObject [
	date := anObject
]

{ #category : #loading }
MooseProjectVersion >> getMooseModel [
	self mooseProject loadVersion: self.
	^ mooseModel first
]

{ #category : #comparing }
MooseProjectVersion >> hash [
	^ (self date hash + self modelClass hash) hashMultiply
]

{ #category : #testing }
MooseProjectVersion >> isCopy [
	^ self mooseSource isCopy
]

{ #category : #testing }
MooseProjectVersion >> isModelLoaded [
	^ mooseModel first isNotNil
]

{ #category : #merging }
MooseProjectVersion >> mergeWithVersion: aMooseVersion usingBlock: aMergingBlock [ 
	aMergingBlock value: aMooseVersion value: self
]

{ #category : #accessing }
MooseProjectVersion >> modelClass [
	^ modelClass
]

{ #category : #accessing }
MooseProjectVersion >> modelClass: anObject [
	modelClass := anObject
]

{ #category : #accessing }
MooseProjectVersion >> mooseModel [
	^ (mooseModel first) ifNil: [ self getMooseModel ]
]

{ #category : #accessing }
MooseProjectVersion >> mooseModel: aMooseModel [
	aMooseModel ifNotNil: [ self modelClass: aMooseModel class ].
	mooseModel := Array with: aMooseModel
]

{ #category : #accessing }
MooseProjectVersion >> mooseProject [
	^ mooseProject
]

{ #category : #accessing }
MooseProjectVersion >> mooseProject: anObject [
	mooseProject := anObject
]

{ #category : #accessing }
MooseProjectVersion >> mooseSource [
	^ mooseSource
]

{ #category : #accessing }
MooseProjectVersion >> mooseSource: anObject [
	mooseSource := anObject
]

{ #category : #accessing }
MooseProjectVersion >> persist [
	self mooseProject persistVersion: self
]

{ #category : #accessing }
MooseProjectVersion >> persisted [
	"processed when the version has been persisted"
	mooseModel ifNotNil: [ mooseModel:= WeakArray with: mooseModel first ]
]

{ #category : #printing }
MooseProjectVersion >> printOn: aStream [
	super printOn: aStream.
	self versionName ifNotNil: [:aName | aStream << aName; << ' '].
	aStream << '['.
	self date printOn: aStream.
	aStream << ']'.
	
]

{ #category : #testing }
MooseProjectVersion >> sourceHasRootFolder [
	^ self mooseSource isNotNil and: [ self mooseSource hasProjectRootFolder ]
]

{ #category : #updating }
MooseProjectVersion >> updatePathOfModelTo: aStringPath [
	self mooseModel rootFolder: aStringPath.
	self mooseModel privateState flushGroups.
	self mooseSource directory: aStringPath
]

{ #category : #accessing }
MooseProjectVersion >> versionName [

	^ versionName
]

{ #category : #accessing }
MooseProjectVersion >> versionName: aString [

	versionName := aString
]
