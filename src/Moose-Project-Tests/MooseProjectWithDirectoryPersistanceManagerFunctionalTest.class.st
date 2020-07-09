Class {
	#name : #MooseProjectWithDirectoryPersistanceManagerFunctionalTest,
	#superclass : #TestCase,
	#instVars : [
		'mooseProject',
		'directoryPersistanceManager',
		'persistanceDirectory'
	],
	#category : #'Moose-Project-Tests'
}

{ #category : #helpers }
MooseProjectWithDirectoryPersistanceManagerFunctionalTest >> mockModel [
	| model type |
	model := FamixTest1Model new.
	type := (FamixTest1Class named: 'Test')
		mooseModel: model;
		yourself.
	(FamixTest1Method named: 'method')
		mooseModel: model;
		parentType: type.
	^ model
]

{ #category : #running }
MooseProjectWithDirectoryPersistanceManagerFunctionalTest >> setUp [
	| sourceDirectory |
	super setUp.
	persistanceDirectory := 'tempPersistanceDirectory' asFileReference.
	sourceDirectory := Mock named: 'sourceDirectory'.
	sourceDirectory stub asFileReference willReturn: sourceDirectory.
	mooseProject := MooseProject fromSourceHolderDirectory: sourceDirectory persistanceDirectory: persistanceDirectory.
	directoryPersistanceManager := mooseProject persistanceManager
]

{ #category : #running }
MooseProjectWithDirectoryPersistanceManagerFunctionalTest >> tearDown [
	persistanceDirectory deleteAll.
	self deny: persistanceDirectory exists.
	super tearDown
]

{ #category : #tests }
MooseProjectWithDirectoryPersistanceManagerFunctionalTest >> testAddVersion [
	| newVersion versionDirectory |
	newVersion := MooseProjectVersion new
		mooseModel: self mockModel;
		date: DateAndTime now.
	mooseProject addVersion: newVersion.
	"The version and the fuel file for mooseProject"
	self assert: persistanceDirectory children size equals: 2.
	versionDirectory := directoryPersistanceManager obtainDirectoryDated: newVersion date.
	self assert: (versionDirectory / 'model.mse') exists
]

{ #category : #tests }
MooseProjectWithDirectoryPersistanceManagerFunctionalTest >> testCreation [
	self assert: persistanceDirectory exists
]

{ #category : #tests }
MooseProjectWithDirectoryPersistanceManagerFunctionalTest >> testSaveMooseProjectObjectDoNotLoseTheModelLink [
	| newVersion model |
	"we store model in a local variable to avoid the weak link is the only pointer to the model (and so it will be garbage collected)"
	model := self mockModel.
	newVersion := MooseProjectVersion new
		mooseModel: model;
		date: DateAndTime now.
	mooseProject addVersion: newVersion.
	self assert: newVersion isModelLoaded.
	mooseProject saveMooseProjectObject.
	self assert: newVersion isModelLoaded.
	self assert: model equals: newVersion mooseModel
]

{ #category : #tests }
MooseProjectWithDirectoryPersistanceManagerFunctionalTest >> testSaveVersionFailDoesNotCorruptPreviousMSE [
	| newVersion mseContent corruptedEntity versionDirectory |
	self flag: #clean.	"We should have a real mock to not depend on Moose in this test."
	newVersion := MooseProjectVersion new
		mooseModel: self mockModel;
		date: DateAndTime now;
		mooseSource: MooseDirectorySource new.
	mooseProject addVersion: newVersion.
	versionDirectory := directoryPersistanceManager obtainDirectoryDated: newVersion date.
	mseContent := (versionDirectory / 'model.mse') contents.
	corruptedEntity := MooseProjectEntityOutsideMetamodel new.
	newVersion mooseModel add: corruptedEntity.
	self should: [ newVersion persist ] raise: Error.
	self assert: (versionDirectory / 'model.mse') contents equals: mseContent
]
