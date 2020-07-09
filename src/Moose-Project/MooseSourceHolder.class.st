"
A MooseSourceHolder is a generic source holder, it can link a cvs, a directory...

Instance Variables

"
Class {
	#name : #MooseSourceHolder,
	#superclass : #Object,
	#category : #'Moose-Project'
}

{ #category : #adding }
MooseSourceHolder >> addSource: aSource [
	self subclassResponsibility 
]

{ #category : #versions }
MooseSourceHolder >> closestDateTo: aDate [ 
	self subclassResponsibility .
]

{ #category : #versions }
MooseSourceHolder >> latestSources [
	self subclassResponsibility 
]

{ #category : #versions }
MooseSourceHolder >> latestVersionDate [
	^ self subclassResponsibility 
]

{ #category : #testing }
MooseSourceHolder >> requireSourcePersistance [
	^ false
]

{ #category : #versions }
MooseSourceHolder >> sourcesAtDate: aDate [
	self subclassResponsibility 
]
