"
A MooseProject encapsulate a project and allow you to manage it easily and obtain MooseModel, HismoModel...

Instance Variables

"
Class {
	#name : #MooseProject,
	#superclass : #Object,
	#instVars : [
		'versions',
		'sourceHolder',
		'mooseModelGenerator',
		'persistanceManager',
		'mergingBlock',
		'genericDictionary',
		'generationInProgress'
	],
	#category : #'Moose-Project'
}

{ #category : #'instance creation' }
MooseProject class >> fromSourceHolderDirectory: aDirectory [
	^ self new
		sourceHolder: (MooseSourceHolderDirectory on: aDirectory);
		yourself
]

{ #category : #'instance creation' }
MooseProject class >> fromSourceHolderDirectory: aDirectory generator: aMooseModelGenerator [
	^ (self fromSourceHolderDirectory: aDirectory) mooseModelGenerator: aMooseModelGenerator 
]

{ #category : #'instance creation' }
MooseProject class >> fromSourceHolderDirectory: aDirectory persistanceDirectory: aPersistanceDirectory [
	^ self new
		sourceHolder: (MooseSourceHolderDirectory on: aDirectory);
		persistanceManager: (MooseProjectDirectoryPersistanceManager directory: aPersistanceDirectory);
		yourself
]

{ #category : #loading }
MooseProject class >> loadFromDirectory: aPersistedMooseProjectDirectory [
	^ MooseProjectDirectoryPersistanceManager loadFromDirectory: aPersistedMooseProjectDirectory asFileReference
]

{ #category : #'instance creation' }
MooseProject class >> persistanceDirectory: aPersistanceDirectory [
	^ self new
		persistanceManager: (MooseProjectPersistanceManager managerClass directory: aPersistanceDirectory);
		yourself
]

{ #category : #adding }
MooseProject >> addSource: aMooseSource [
	self sourceHolder addSource: aMooseSource
]

{ #category : #adding }
MooseProject >> addVersion: aMooseProjectVersion [
	self versions add: aMooseProjectVersion.
	aMooseProjectVersion mooseProject: self.
	[ self persistVersion: aMooseProjectVersion ]
		on: NoPersistanceManagerException
		do: [ 
			"nothing"
			 ]
]

{ #category : #adding }
MooseProject >> addVersionFromMSE: aMSEStream dated: aDateTime [
	self
		addVersion:
			(MooseProjectVersion new
				date: aDateTime;
				mooseModel: (self mooseModelGenerator new modelClass new importFromMSEStream: aMSEStream);
				yourself)
]

{ #category : #private }
MooseProject >> changeMyStateForGenerationDone [
	self generationInProgress: false
]

{ #category : #private }
MooseProject >> changeMyStateForGenerationFail [
	self generationInProgress: false
]

{ #category : #private }
MooseProject >> changeMyStateForGenerationInProgress [
	self ensureGenerationIsPossible.
	self generationInProgress: true
]

{ #category : #testing }
MooseProject >> ensureGenerationIsPossible [
	self generationInProgress
		ifTrue: [ GenerationNotAllowedException signal: 'A generation is still in progress' ]
]

{ #category : #generation }
MooseProject >> generateLatestVersion [
	^ self generateVersionFromSource: (self sourceHolder latestSources)
]

{ #category : #generation }
MooseProject >> generateVersionAtDate: aDate [
	^ self generateVersionFromSource: (self sourceHolder sourcesAtDate: aDate)
]

{ #category : #generation }
MooseProject >> generateVersionFromSource: source [
	
	^ self generateVersionFromSource: source named: nil
]

{ #category : #generation }
MooseProject >> generateVersionFromSource: source named: aString [
	[ 
	| newVersion currentSource |
	currentSource := source.
	self changeMyStateForGenerationInProgress.
	'Generating Version'
		displayProgressFrom: 1
		to: 300
		during: [ :bar | 
			bar title: 'Obtain latest sources'.
			bar increment.
			self isPersistanceRequiredForSources
				ifTrue: [ 
					bar title: 'Copy sources'.
					bar increment.
					currentSource := self obtainPersistanceManager persistSources: currentSource ].
			bar title: 'Generate latest version'.
			bar increment.
			newVersion := self newProjectVersion
				mooseSource: currentSource;
				mooseModel: (self mooseModelGenerator runOn: currentSource directory);
				date: currentSource date;
				yourself.
			aString ifNotNil: [newVersion versionName:  aString ].
			bar title: 'Merging with previous version'.
			296 timesRepeat: [ bar increment ].
			[ newVersion mergeWithVersion: self latestGeneratedVersion usingBlock: self mergingBlock ]
				on: NoGeneratedVersionException
				do: [  ].
			self changeMyStateForGenerationDone.
			self addVersion: newVersion.
			^ newVersion ] ]
		on: Error
		do: [ :err | 
			self changeMyStateForGenerationFail.
			err signal ]
]

{ #category : #accessing }
MooseProject >> generatedVersionAtDate: aDate [
	^ self versions detect: [ :aVersionDate | aVersionDate = aDate ]
]

{ #category : #accessing }
MooseProject >> generatedVersionClosestToDate: aDate [
	^ ((self versions reject: [ :aVersion | aVersion date > aDate ]) detectMin: [ :aVersion | aDate - aVersion date ])
		ifNil: [ NotFound signal ]
]

{ #category : #accessing }
MooseProject >> generationInProgress [
	^ generationInProgress
]

{ #category : #accessing }
MooseProject >> generationInProgress: anObject [
	generationInProgress := anObject
]

{ #category : #accessing }
MooseProject >> genericDictionary [
	genericDictionary ifNil: [ genericDictionary := Dictionary new ].
	^ genericDictionary
]

{ #category : #accessing }
MooseProject >> genericDictionary: anObject [
	genericDictionary := anObject
]

{ #category : #accessing }
MooseProject >> getAllModels [
	^ self versions collect: #mooseModel
]

{ #category : #accessing }
MooseProject >> getMooseModel [
	^ self latestGeneratedVersion getMooseModel
]

{ #category : #testing }
MooseProject >> hasPersistanceManager [
	^ self persistanceManager isNotNil
]

{ #category : #initialization }
MooseProject >> initialize [ 
	super initialize.
	self generationInProgress: false.
	versions := OrderedCollection new.
	mergingBlock := [ :previousVersion :newVersion | ]
]

{ #category : #testing }
MooseProject >> isPersistanceRequiredForSources [
	^ (self sourceHolder isNil or: [ self sourceHolder requireSourcePersistance ]) and: [ self hasPersistanceManager ]
]

{ #category : #accessing }
MooseProject >> latestGeneratedVersion [
	self versions ifEmpty: [ NoGeneratedVersionException signal ].
	^ self versions sorted last
]

{ #category : #versions }
MooseProject >> latestVersion [
	"Check if a newest version is available from the sourceHolder"

	(self versions isEmpty or:[ self sourceHolder latestVersionDate > self latestGeneratedVersion date])
		ifTrue: [ self generateLatestVersion ].
	^ self latestGeneratedVersion
]

{ #category : #loading }
MooseProject >> loadVersion: aMooseProjectVersion [ 
	^ self obtainPersistanceManager loadVersion: aMooseProjectVersion.
]

{ #category : #adding }
MooseProject >> mergeWith: aMooseProject [
	(aMooseProject versions reject: [ :version | self versions includes: version ])
		do: [ :version | 
			| versionToAdd |
			versionToAdd := version copy.
			self versions add: versionToAdd.
			versionToAdd mooseProject: self ]
]

{ #category : #accessing }
MooseProject >> mergingBlock [
	^ mergingBlock
]

{ #category : #accessing }
MooseProject >> mergingBlock: anObject [
	mergingBlock := anObject
]

{ #category : #accessing }
MooseProject >> mooseModel [
	^ self latestGeneratedVersion mooseModel
]

{ #category : #accessing }
MooseProject >> mooseModelGenerator [
	^ mooseModelGenerator
]

{ #category : #accessing }
MooseProject >> mooseModelGenerator: anObject [
	mooseModelGenerator := anObject
]

{ #category : #printing }
MooseProject >> mooseName [
	^ self name
]

{ #category : #'instance creation' }
MooseProject >> newProjectVersion [
	^ MooseProjectVersion new
]

{ #category : #testing }
MooseProject >> noGeneratedVersions [
	^ self versions isEmpty
]

{ #category : #accessing }
MooseProject >> obtainPersistanceManager [
	self persistanceManager ifNil: [ NoPersistanceManagerException signal ].
	^ self persistanceManager
]

{ #category : #accessing }
MooseProject >> persist [
	self obtainPersistanceManager persistMooseProject 
]

{ #category : #accessing }
MooseProject >> persistVersion: aMooseProjectVersion [ 
	self obtainPersistanceManager persistVersion: aMooseProjectVersion
]

{ #category : #accessing }
MooseProject >> persistanceManager [
	^ persistanceManager
]

{ #category : #accessing }
MooseProject >> persistanceManager: anObject [
	persistanceManager := anObject.
	persistanceManager mooseProject: self.
]

{ #category : #accessing }
MooseProject >> saveMooseProjectObject [
	"save only the object and do not persist all versions like persist do.
	Used to retain things placed in the generic dictionary"

	self obtainPersistanceManager saveMooseProjectObject
]

{ #category : #accessing }
MooseProject >> sourceHolder [
	^ sourceHolder
]

{ #category : #accessing }
MooseProject >> sourceHolder: anObject [
	sourceHolder := anObject
]

{ #category : #accessing }
MooseProject >> versionCloseToDate: aDate [
	^ [ self generatedVersionAtDate: (self sourceHolder closestDateTo: aDate) ]
		on: NotFound
		do: [ self addVersion: (self generateVersionAtDate: aDate) ]
]

{ #category : #accessing }
MooseProject >> versions [
	^ versions
]
