Reform - Setup
==============

Building the app
----------------

The project repository contains an Xcode7-Workspace(Reform.xcworkspace) with 8 Xcode projects.

The application can be built by opening the workspace in Xcode and selecting the "ReformApplication" Scheme.


Project structure
-----------------

The Project is split into multiple Xcode projects which partially depend on each other.

This separation in projects is made to emphasize a layer architecture.

As reform is an drawing application it would be easy to mix up the model and the ui layer. This mixup shall be prevented.

NSColor and NSBeszierPath structs must not be used in the model layer

- ReformGraphics: Defines the privitimes used to compose a vector graphics. It belongs to the model layer and allows constructing (colored) shapes without relaying on the NSBesizrPath api/AppKit/Cocoa

- ReformExpression: The library for parsing and evaluating mathematical expressions

- ReformSerializer: Provides functions to serialize and deserialize a project

- ReformTools: Defines the tools available to the user for manipulating the picture

- ReformStage: Defines the presentation of the picture on the canvas for editing. Does not include the tools for editing. Does not depend on Appkit/Cocoa

- ReformMath: Contains functions and types to support 2D vector math. May be replaced with some other vector library in the future.

- ReformCore: The core project defining all types required to define a dynamic picture and the runtime needed to evaluate it.

- ReformApplication: The only project/component relying on AppKit. It contains all the controllers and adapters to present the picture, stage and editing tools through a Cocoa interface
