Every Control should have the following few states for which one could assign a command(list of commands):

* On 	-- Got focus. user taps and holds the control
* Off 	-- Lost focus. user released the finger but not on the control area
* Hit	-- Finger released in the control area.. can be used as a button tapped event. Note: the Off command is executed too!
* Slide -- Finger moving while control focused (touched). Slide triggered for every received from iPhoneOS move action

Commands should go like this:

* OnCommand
* OffCommand
* HitCommand (Also executes the OffCommand)
* SlideCommand

Any of the above can be applied to any control in the UI. All 4 are optional.

Usage:

OnCommand =    "name,MyButton;zoom,2.5,0.5" // Set the name on initialization and any time you focus you get the control start zooming to 2.5x in 0.5 seconds time
OffCommand =   "zoom,1.0,0.2" // When focus lost - zoom back to normal
HitCommand =   "sleep,0.3;screen,OtherScreen" // Wait 0.3 seconds and switch to screen called OtherScreen
SlideCommand = "move,{touch:x},{touch:y}" // (nonexisting command) Move to the location where you moved your finger too

Only one control should have focus at a given time.
If control got focus and finger dragged outside the control's active area the OffCommand should be triggered and focus should be removed from the control.

