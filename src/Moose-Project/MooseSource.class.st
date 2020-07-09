"
I represent one source for a project, it can be a source directory for one version, a svn version...
"
Class {
	#name : #MooseSource,
	#superclass : #Object,
	#instVars : [
		'date',
		'isCopy'
	],
	#category : #'Moose-Project'
}

{ #category : #accessing }
MooseSource >> date [
	^ date
]

{ #category : #accessing }
MooseSource >> date: anObject [
	date := anObject
]

{ #category : #rootFolder }
MooseSource >> hasProjectRootFolder [
	^ self projectRootFolder isNotNil
]

{ #category : #initialization }
MooseSource >> initialize [
	super initialize.
	self isCopy: false
]

{ #category : #accessing }
MooseSource >> isCopy [
	^ isCopy
]

{ #category : #accessing }
MooseSource >> isCopy: anObject [
	isCopy := anObject
]

{ #category : #persistance }
MooseSource >> persistWith: aMooseProjectPersistanceManager [ 
	^ self subclassResponsibility 
]

{ #category : #rootFolder }
MooseSource >> projectRootFolder [
	^ self subclassResponsibility 
]
