Class {
	#name : #MooseProjectMockTest,
	#superclass : #TestCase,
	#instVars : [
		'mooseProject',
		'version1',
		'version2',
		'version3',
		'sourceHolder',
		'persistanceManager',
		'modelGenerator'
	],
	#category : #'Moose-Project-Tests'
}

{ #category : #running }
MooseProjectMockTest >> setUp [
	| versions |
	super setUp.
	mooseProject := MooseProject new.
	version1 := Mock named: 'version1'.
	version2 := Mock named: 'version2'.
	version3 := Mock named: 'version3'.
	versions := {version1 . version2 . version3}.
	versions do: [ :aVersion | (aVersion stub mooseProject: Any) willReturn: mooseProject ].
	sourceHolder := Mock named: 'sourceHolder'.
	modelGenerator := Mock named: 'modelGenerator'.
	mooseProject mooseModelGenerator: modelGenerator.
	persistanceManager := Mock named: 'persistanceManager'.
	(persistanceManager stub mooseProject: Any) willReturn: mooseProject.
	mooseProject persistanceManager: persistanceManager.
	versions do: [ :aVersion | (persistanceManager stub persistVersion: Any) willReturn: aVersion ].
	mooseProject
		sourceHolder: sourceHolder;
		addVersion: version1;
		addVersion: version2;
		addVersion: version3.
	version1 stub <= version2 willReturn: true.
	version2 stub <= version3 willReturn: true.
	version1 stub <= version3 willReturn: true
]

{ #category : #tests }
MooseProjectMockTest >> testAddingVersions [
	"everything is in the setUp"
]

{ #category : #tests }
MooseProjectMockTest >> testGetAllModels [
	| model1 model2 model3 |
	model1 := Mock named: 'model1'.
	model2 := Mock named: 'model2'.
	model3 := Mock named: 'model3'.
	version1 stub mooseModel willReturn: model1.
	version2 stub mooseModel willReturn: model2.
	version3 stub mooseModel willReturn: model3.
	self
		assert: mooseProject getAllModels
		equals:
			{model1.
			model2.
			model3} asOrderedCollection
]

{ #category : #tests }
MooseProjectMockTest >> testLatestVersionWhenGenerationIsNotRequired [
	| latestDate versionDate |
	latestDate := Mock named: 'latestDate'.
	versionDate := Mock named: 'versionDate'.
	version3 stub date willReturn: versionDate.
	sourceHolder stub latestVersionDate willReturn: latestDate.
	(latestDate stub > versionDate) willReturn: false.
	self assert: mooseProject latestVersion equals: version3.
	sourceHolder should receive latestVersionDate.
	latestDate should receive > versionDate
]

{ #category : #tests }
MooseProjectMockTest >> testLatestVersionWhenGenerationIsRequired [
	| latestDate versionDate source model latestVersion |
	latestDate := Mock named: 'latestDate'.
	latestDate stub asEmailString willReturn: 'mock date'.
	versionDate := Mock named: 'versionDate'.
	version3 stub date willReturn: versionDate.
	sourceHolder stub latestVersionDate willReturn: latestDate.
	sourceHolder stub requireSourcePersistance willReturn: false.
	source := Mock named: 'source'.
	source stub date willReturn: latestDate.
	model := Mock named: 'model'.
	(modelGenerator stub runOn: Any) willReturn: model.
	sourceHolder stub latestSources willReturn: source.
	latestDate stub > versionDate willReturn: true.
	version3 stub <= Any willReturn: true.
	latestVersion := mooseProject latestVersion.
	self assert: latestVersion mooseModel equals: model.
	self assert: latestVersion date equals: latestDate.
	version3 should receive date.
	persistanceManager should receive persistVersion: Any.
	sourceHolder should receive latestVersionDate.
	sourceHolder should receive requireSourcePersistance.
	source should receive date.
	modelGenerator should receive runOn: Any.
	sourceHolder should receive latestSources.
	latestDate should receive > versionDate.
	version3 can receive <= Any
]

{ #category : #tests }
MooseProjectMockTest >> testMergingVersion [
	| latestDate versionDate source model |
	"Check that the merging block is applied when generating new version"
	mooseProject mergingBlock: [ :previous :new | previous access ].
	latestDate := Mock named: 'latestDate'.
	latestDate stub asEmailString willReturn: 'mock date'.
	versionDate := Mock named: 'versionDate'.
	version3 stub date willReturn: versionDate.
	sourceHolder stub latestVersionDate willReturn: latestDate.
	sourceHolder stub requireSourcePersistance willReturn: false.
	source := Mock named: 'source'.
	source stub date willReturn: latestDate.
	model := Mock named: 'model'.
	(modelGenerator stub runOn: Any) willReturn: model.
	sourceHolder stub latestSources willReturn: source.
	latestDate stub > versionDate willReturn: true.
	version3 stub <= Any willReturn: true.
	mooseProject latestVersion.
	version3 should receive access.
	version3 should receive date.
	persistanceManager should receive persistVersion: Any.
	sourceHolder should receive latestVersionDate.
	sourceHolder should receive requireSourcePersistance.
	source should receive date.
	modelGenerator should receive runOn: Any.
	sourceHolder should receive latestSources.
	latestDate should receive > versionDate
]

{ #category : #tests }
MooseProjectMockTest >> testMultipleGenerationAtSameTime [
	| sources block |
	block := false.
	sources := Mock named: 'sources'.
	sourceHolder stub latestSources willReturn: sources.
	sources stub date willReturn: Date today.
	sourceHolder stub requireSourcePersistance willReturn: false.
	(modelGenerator stub runOn: Any)
		will: [ "Here we block with a loop the first thread and unlock the second"
			block := true.
			[ block ] whileTrue ].
	[ mooseProject generateLatestVersion ] fork.	"here we ensure that the first thread has the priority for generation"
	[ block ] whileFalse.
	self should: [ mooseProject generateLatestVersion ] raise: GenerationNotAllowedException.
	block := false.
	modelGenerator should receive runOn: Any
]

{ #category : #tests }
MooseProjectMockTest >> testObtainLatestGeneratedVersion [
	self assert: mooseProject latestGeneratedVersion equals: version3.
]
