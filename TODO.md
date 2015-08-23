TODO
====

Quality
-------
The overall project quality needs to be improved by:

- [ ] Write tests (unittests, integrationtests)
- [ ] Write documentation
- [ ] Use standard vector libary
- [x] simplify if/guard "let" statements
- [ ] implement Equatable for all structs/enums
- [ ] revisit all struct-vs-class decisions
- [ ] revisit degeneratable protocol

Graphics
--------
- [ ] improve icons for the toolbar

Promotion
---------
- [ ] creat a simple singlepage homepage/landingpage for the project
- [ ] videos with sound (currently the youtube videos showing of the application have no soundtrack)

Performance
-----------
The application is not slow but maybe there is still room for improvements

- [ ] Profile application with Xcode profilers
- [ ] QuadTree for Stage content?
- [ ] Switch from Double to Float for entity positions?
- [ ] lazy intersection calculation when entity-count is height

Swift
-----
The following was already implement in java but has to be ported/adopted to the swift implementation

- [ ] make forms markable as "guide"
- [ ] Generate correct form names
- [ ] EventFlow (stream api? notificationcenter?)
- [ ] Analyzer: collect nodes
- [ ] Draw Arc
- [ ] Selection Tool
- [ ] Picture Tool / Recursion
- [ ] Reduce Code duplication for Tools
- [ ] Crop Tool
- [ ] Preview Tool
- [ ] Export Tool
- [ ] SPACE-key preview
- [ ] Procedure-View
- [ ] snapshot collector
- [ ] preview collector
- [ ] Save/Load
- [ ] Data-View
- [ ] Measurement-View
- [ ] Picture-Selection
- [ ] Creation-Tool Dropdown
- [ ] Make toolbar hightlight robust
- [ ] Menubar
- [ ] Non-Rotation-Handles (Arc, Pie)
- [ ] Auto-center Circle
- [ ] Formtype-dependent striehtening
- [ ] fix responder-chain for toolbar
- [ ] improve controller hirarchie/documentbased architecture
- [ ] Window-Title/Filepath
- [ ] Fix canvas clipping/Infinite Canvas
- [ ] FormAttributes: Colors, Stroke
- [ ] custom attributes
- [ ] Tooltips
- [ ] Negative Pie scaling
- [ ] Improve Angle-range handling
- [ ] Text Rendering
- [ ] Multiple Windows/Projects
- [ ] Canvas focus/default responder
- [ ] color chooser
- [ ] fix arc/pie intersections
- [ ] simplify glomp/intersection calculation
- [ ] simplify/unify linesegment/arc/shape/path/hitarea api

Far future concepts:
--------------------
broad features which require some planing

- [ ] Accessibility
- [ ] learn about cocoa/appkit accessibility
- [ ] find a way to implement UI/tools in an accessible ways
- [ ] Multi languagal
- [ ] Optimize energy usage
- [ ] Filters (Shadershop-like)

Conceptually open:
------------------
features for which is not yet decided how to implement them in detail or how they should work/behave

- [ ] Iterate over points
- [ ] Itetate over forms
- [ ] "Reference"-forms in difference colors with generalized snap/grap points
- [ ] Form Groups (transform multiple forms in one step)
- [ ] Snap point filter (option to show only snap points of selected form)
- [ ] Path Tool (Runtime Heap to store path points)
- [ ] Array-Values in Expressions
- [ ] Export animation (eg gif)
- [ ] Export JavaScript (eg d3)
- [ ] Export bytecode
- [ ] Zoom/Camera
- [ ] Masking (Instruction scopes?)
- [ ] Layers, Boolean Combination
- [ ] List of errors
- [ ] Magnets
- [ ] Rulers (vertical and horinzontally lines, position stored in %)
- [ ] snap to grid (configurable grid size, store location in %)

Minor improvements:
-------------------

- [ ] color constants: red, green, blue, cyan, yellow, megenta...
- [ ] expression table column sorting
- [ ] Duplicating Definitions
- [ ] Duplicating Pictures

Open:
-----
features which are streightforward to implement

- [ ] Tool State description (anymore???)
- [ ] changeable Form names
- [ ] Undo/Redo
- [ ] Manual No-Snap mode
- [ ] merge consecutive instructions if possible
- [ ] improve scrolling when resizing canvas
- [ ] Increment/Decrement Expressions
- [ ] Iteration Focus
- [ ] Multiple Instruction Selection
- [ ] Improve Error-Checking in analyzer and runtime regarding expressions
- [ ] Add Expression-Distance
- [ ] Add Expression-Destination

UI:
---
improvements on the user interface

- [ ] icons for instructions in procedure view
- [ ] mark instructions affecting or depending on selected form
- [ ] folding group instructions
- [ ] label instructions
- [ ] expression autocomplete

In Progress (java):
-------------------
features which are already partially implemented in java but not yet finished

- [ ] Recursion
- [ ] simplify recursion runtime listener
- [ ] refresh outer picture if embedded picture changes
- [ ] later instruction changes
- [ ] Data Grid / Measurements
- [ ] Fix loop-nesting-protection
- [ ] Adjust serializer to support latest changes

Bugs (java):
------------
bugs in the java implementation

- [ ] fix degenerated arc rotation
- [ ] keep selection when canceling tool (focus get's reset)
- [ ] sort shapes correctly

Not important:
--------------
- [ ] Rewrite tokenizer
- [ ] simplify arc/pie calculation
