"
A MooseProjectPersistanceManager is the abstract class for a moose model persister.

Instance Variables

"
Class {
	#name : #MooseProjectPersistanceManager,
	#superclass : #Object,
	#instVars : [
		'mooseProject'
	],
	#classInstVars : [
		'managerClass'
	],
	#category : #'Moose-Project'
}

{ #category : #accessing }
MooseProjectPersistanceManager class >> defaultManagerClass [

	^ MooseProjectDirectoryPersistanceManager 
]

{ #category : #accessing }
MooseProjectPersistanceManager class >> managerClass [

	"Answers the class to be used to instanciate persistance manager of a moose project.
	Persistance manager is initialized as soon as the synectique server (image) is launched (#launchFrom: ).
	It implicitely happens by sending #persistanceDirectory: to a MooseProject.
	
	"
	^ managerClass ifNil: [self defaultManagerClass  ]
]

{ #category : #accessing }
MooseProjectPersistanceManager class >> managerClass: aClass [

	managerClass := aClass
]

{ #category : #loading }
MooseProjectPersistanceManager >> loadVersion: aMooseProjectVersion [ 
	self subclassResponsibility .
]

{ #category : #accessing }
MooseProjectPersistanceManager >> mooseProject [
	^ mooseProject
]

{ #category : #accessing }
MooseProjectPersistanceManager >> mooseProject: anObject [
	mooseProject := anObject
]

{ #category : #persistance }
MooseProjectPersistanceManager >> persistDirectorySource: aMooseDirectorySource [ 
	^ self subclassResponsibility 
]

{ #category : #persistance }
MooseProjectPersistanceManager >> persistMooseProject [
	self mooseProject versions do: [ :aVersion | self persistVersion: aVersion ].
	self saveMooseProjectObject.
]

{ #category : #persistance }
MooseProjectPersistanceManager >> persistSources: aMooseSource [ 
	^ aMooseSource persistWith: self
]

{ #category : #persistance }
MooseProjectPersistanceManager >> persistVersion: aMooseProjectVersion [
	self subclassResponsibility 
]

{ #category : #persistance }
MooseProjectPersistanceManager >> saveMooseProjectObject [
	self subclassResponsibility 
]
