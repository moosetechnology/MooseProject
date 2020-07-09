"
I represent the source for a version on the directory.
"
Class {
	#name : #MooseDirectorySource,
	#superclass : #MooseSource,
	#instVars : [
		'directory'
	],
	#category : #'Moose-Project'
}

{ #category : #'instance creation' }
MooseDirectorySource class >> copyDated: aDate directory: aDirectory [
	^ self new
		date: aDate;
		directory: aDirectory;
		isCopy: true;
		yourself
]

{ #category : #'instance creation' }
MooseDirectorySource class >> date: aDate directory: aDirectory [
	^ self new
		date: aDate;
		directory: aDirectory;
		yourself
]

{ #category : #accessing }
MooseDirectorySource >> directory [
	^ directory
]

{ #category : #accessing }
MooseDirectorySource >> directory: anObject [
	directory := anObject
]

{ #category : #persistance }
MooseDirectorySource >> persistWith: aMooseProjectPersistanceManager [ 
	^ aMooseProjectPersistanceManager persistDirectorySource: self
]

{ #category : #rootFolder }
MooseDirectorySource >> projectRootFolder [
	^ self directory
]
