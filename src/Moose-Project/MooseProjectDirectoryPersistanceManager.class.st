"
A MooseProjectDirectoryPersistanceManager is a persister of MooseModel on disk.

Instance Variables
	rootDirectory:		<Object>

rootDirectory
	- xxxxx

"
Class {
	#name : #MooseProjectDirectoryPersistanceManager,
	#superclass : #MooseProjectPersistanceManager,
	#instVars : [
		'rootDirectory'
	],
	#category : #'Moose-Project'
}

{ #category : #accessing }
MooseProjectDirectoryPersistanceManager class >> directory: aDirectory [
	^ self new rootDirectory: aDirectory asFileReference
]

{ #category : #loading }
MooseProjectDirectoryPersistanceManager class >> loadFromDirectory: aPersistedMooseProjectDirectory [
	| project |
	project := (FLMaterializer materializeFromFileNamed: (aPersistedMooseProjectDirectory / self serializationFile) fullName).
	project obtainPersistanceManager rootDirectory: aPersistedMooseProjectDirectory.
	^ project
]

{ #category : #accessing }
MooseProjectDirectoryPersistanceManager class >> serializationFile [
	^ 'mooseProjectObject.fl'
]

{ #category : #helpers }
MooseProjectDirectoryPersistanceManager >> ensureNoPointerToData [
	^ (self mooseProject versions
		select: #isModelLoaded
		thenCollect: [ :aVersion | 
			| model |
			model := aVersion mooseModel.
			aVersion mooseModel: nil.
			aVersion -> model ]) asDictionary
]

{ #category : #loading }
MooseProjectDirectoryPersistanceManager >> loadVersion: aMooseProjectVersion [ 
	^ self loadVersion: aMooseProjectVersion fromDirectory: (self obtainDirectoryDated: aMooseProjectVersion date) sourceDirectory: (self obtainSourceDirectoryDated: aMooseProjectVersion date)
]

{ #category : #loading }
MooseProjectDirectoryPersistanceManager >> loadVersion: aMooseProjectVersion fromDirectory: aVersionDirectory sourceDirectory: aSourceDirectory [
	| model |
	aVersionDirectory / 'model.mse' readStreamDo: [ :s | model := aMooseProjectVersion modelClass new importFromMSEStream: s ].

	aMooseProjectVersion sourceHasRootFolder ifTrue: [ model rootFolder: aMooseProjectVersion mooseSource projectRootFolder ].

	"After the export we give the possibility to execute some code via a pragma."
	(Pragma
		allNamed: #postLoadingMooseProjectActionPriority:
		from: model
		to: Object
		sortedUsing: [ :pragma | pragma argumentAt: 1 ] ascending)
		do: [ :pragma | model perform: pragma methodSelector withEnoughArguments: {aVersionDirectory . self mooseProject} ].

	aMooseProjectVersion mooseModel: model.
	aMooseProjectVersion persisted
]

{ #category : #helpers }
MooseProjectDirectoryPersistanceManager >> obtainDirectoryDated: aDate [
	^ (self rootDirectory / (aDate asString copyReplaceAll: ':' with: '_') asFileName)
		ensureCreateDirectory;
		yourself
]

{ #category : #helpers }
MooseProjectDirectoryPersistanceManager >> obtainSourceDirectoryDated: aDate [
	^ (self obtainDirectoryDated: aDate) / 'sources'
]

{ #category : #persistance }
MooseProjectDirectoryPersistanceManager >> persistDirectorySource: aMooseDirectorySource [
	| destinationSourceDirectory |
	destinationSourceDirectory := self obtainSourceDirectoryDated: aMooseDirectorySource date.
	aMooseDirectorySource directory copyAllTo: destinationSourceDirectory.
	^ MooseDirectorySource copyDated: aMooseDirectorySource date directory: destinationSourceDirectory
]

{ #category : #persistance }
MooseProjectDirectoryPersistanceManager >> persistVersion: aMooseProjectVersion [

	| versionDirectory |
	versionDirectory := (self obtainDirectoryDated: aMooseProjectVersion date).
	self saveAnnexesForVersion: aMooseProjectVersion inDirectory: versionDirectory.
	self saveModelForVersion: aMooseProjectVersion InDirectory: versionDirectory.
	aMooseProjectVersion persisted.
	self saveMooseProjectObject
]

{ #category : #pointers }
MooseProjectDirectoryPersistanceManager >> restorePointersToData: modelByVersionDictionary [
	modelByVersionDictionary
		keysAndValuesDo:  [ :version :model | 
			version
				mooseModel: model;
				persisted ]
]

{ #category : #accessing }
MooseProjectDirectoryPersistanceManager >> rootDirectory [
	^ rootDirectory
]

{ #category : #accessing }
MooseProjectDirectoryPersistanceManager >> rootDirectory: anObject [
	rootDirectory := anObject asFileReference.
	rootDirectory exists ifFalse: [ rootDirectory createDirectory ]
]

{ #category : #persistance }
MooseProjectDirectoryPersistanceManager >> saveAnnexesForVersion: aMooseProjectVersion inDirectory: aVersionDirectory [
	"Before the export we give the possibility to execute some code via a pragma."

	(Pragma
		allNamed: #preLoadingMooseProjectActionPriority:
		from: aMooseProjectVersion mooseModel class
		to: Object
		sortedUsing: [ :pragma | pragma argumentAt: 1 ] ascending)
		do: [ :pragma | aMooseProjectVersion mooseModel perform: pragma methodSelector withEnoughArguments: {aVersionDirectory . self mooseProject} ]
]

{ #category : #persistance }
MooseProjectDirectoryPersistanceManager >> saveModelForVersion: aMooseProjectVersion InDirectory: aVersionDirectory [
	aVersionDirectory / 'tempModel.mse' writeStreamDo: [ :aStream | aMooseProjectVersion mooseModel exportToMSEStream: aStream ].
	(aVersionDirectory / 'model.mse') ensureDelete.
	aVersionDirectory / 'tempModel.mse' copyTo: aVersionDirectory / 'model.mse'.
	(aVersionDirectory / 'tempModel.mse') ensureDelete
]

{ #category : #persistance }
MooseProjectDirectoryPersistanceManager >> saveMooseProjectObject [
	| pointers |
	pointers := self ensureNoPointerToData.
	FLSerializer serialize: self mooseProject toFileNamed: (self rootDirectory / self class serializationFile) fullName.
	self restorePointersToData: pointers.
]
