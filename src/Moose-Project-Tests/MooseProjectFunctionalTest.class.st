Class {
	#name : #MooseProjectFunctionalTest,
	#superclass : #TestCase,
	#instVars : [
		'mooseProject',
		'sourceHolder',
		'persistanceManager',
		'modelGenerator'
	],
	#category : #'Moose-Project-Tests'
}

{ #category : #running }
MooseProjectFunctionalTest >> setUp [
	super setUp.
	mooseProject := MooseProject new.
	sourceHolder := MooseSourceHolder new.
	modelGenerator := Mock named: 'modelGenerator'.
	mooseProject mooseModelGenerator: modelGenerator.
	persistanceManager := Mock named: 'persistanceManager'.
	(persistanceManager stub mooseProject: Any) willReturn: mooseProject.
	mooseProject persistanceManager: persistanceManager.
	mooseProject sourceHolder: sourceHolder
]

{ #category : #tests }
MooseProjectFunctionalTest >> testGeneratedVersionClosestToDate [
	| version1 version3 |
	mooseProject addVersion: (version1 := MooseProjectVersion new date: (DateAndTime year: 2015 month: 2 day: 22)).
	mooseProject addVersion: (MooseProjectVersion new date: (DateAndTime year: 2015 month: 3 day: 22)).
	mooseProject addVersion: (version3 := MooseProjectVersion new date: (DateAndTime year: 2015 month: 4 day: 22)).
	self assert: (mooseProject generatedVersionClosestToDate: (DateAndTime year: 2015 month: 3 day: 21)) equals: version1.
	self assert: (mooseProject generatedVersionClosestToDate: (DateAndTime year: 2015 month: 10 day: 21)) equals: version3.
	self should: [ mooseProject generatedVersionClosestToDate: (DateAndTime year: 2015 month: 1 day: 21) ] raise: NotFound
]

{ #category : #tests }
MooseProjectFunctionalTest >> testMultipleGenerationOneAfterTheOther [
	| sources |
	sources := Mock named: 'sources'.
	sources stub date willReturn: DateAndTime now.
	2 timesRepeat: [ mooseProject generateVersionFromSource: sources ].
	(persistanceManager should receive persistVersion: Any) twice
]
