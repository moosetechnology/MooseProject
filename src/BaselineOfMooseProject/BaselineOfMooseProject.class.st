"
I am a baseline to define the structure and dependencies of the MooseProject project.
"
Class {
	#name : #BaselineOfMooseProject,
	#superclass : #BaselineOf,
	#category : #BaselineOfMooseProject
}

{ #category : #baseline }
BaselineOfMooseProject >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ "Dependencies"
			self
				famix: spec;
				systemInteraction: spec.

			"Packages"
			spec
				package: 'Moose-Project' with: [ spec requires: #('Famix' 'SystemInteraction') ];
				package: 'Moose-Project-Tests' with: [ spec requires: #('Moose-Project' 'FamixTestModels') ].

			"Groups"
			spec
				group: 'Core' with: #('Moose-Project');
				group: 'Tests' with: #('Moose-Project-Tests') ]
]

{ #category : #dependencies }
BaselineOfMooseProject >> famix: spec [
	spec
		baseline: 'Famix'
			with: [ spec
				loads: #('Minimal');
				repository: 'github://moosetechnology/Famix:development/src' ];
		project: 'FamixTestModels' copyFrom: 'Famix' with: [ spec loads: 'TestModels' ]
]

{ #category : #accessing }
BaselineOfMooseProject >> projectClass [
	^ MetacelloCypressBaselineProject
]

{ #category : #dependencies }
BaselineOfMooseProject >> systemInteraction: spec [
	spec baseline: 'SystemInteraction' with: [ spec repository: 'github://jecisc/SystemInteraction:v1.x.x/src' ]
]
