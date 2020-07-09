Class {
	#name : #MooseProjectDirectoryPersistanceManagerTest,
	#superclass : #TestCase,
	#instVars : [
		'mooseProject',
		'directoryPersistanceManager',
		'directory'
	],
	#category : #'Moose-Project-Tests'
}

{ #category : #running }
MooseProjectDirectoryPersistanceManagerTest >> setUp [
	super setUp.
	directory := Mock named: 'directory'.
	directory stub asFileReference willReturn: directory.
	directory stub exists willReturn: true.
	mooseProject := Mock named: 'mooseProject'.
	directoryPersistanceManager := MooseProjectDirectoryPersistanceManagerFake new rootDirectory: directory.
	directoryPersistanceManager mooseProject: mooseProject
]

{ #category : #tests }
MooseProjectDirectoryPersistanceManagerTest >> testPersistVersion [
	| version date versionDirectory mooseModel file file2 modelClass |
	version := Mock named: 'version'.
	versionDirectory := Mock named: 'versionDirectory'.
	modelClass := Mock named: 'model class'.
	versionDirectory stub exists willReturn: true.
	directory stub / Any willReturn: versionDirectory.
	date := DateAndTime
		year: 1986
		month: 10
		day: 16
		hour: 5
		minute: 0
		second: 0.
	version stub date willReturn: date.
	mooseModel := Mock named: 'mooseModel'.
	mooseProject stub versions willReturn: #().
	version stub mooseModel willReturn: mooseModel.
	version stub modelClass willReturn: modelClass.
	file := (FileSystem memory / 'file')
		ensureCreateFile;
		yourself.
	file2 := FileSystem memory / 'file2'.
	versionDirectory stub / file basename willReturn: file.
	versionDirectory stub / file2 basename willReturn: file2.
	directoryPersistanceManager persistVersion: version.
	version should receive persisted
]
