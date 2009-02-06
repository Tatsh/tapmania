File format should do the magic:

Files starting with '_' are files to keep in memory always. These are loaded once at startup and probably never released.
Example: _MainMenu Background.png, _SongLoader AnimatingIcon_16x16.png

Files with '_NxM' suffix are automatically loaded as framed textures (eg. SomeScreen SomeTexMap_5x1.png) where N is the number of columns and M is the number of rows.
The frame sizes are determined automatically.

Special files called redirection files can be created. These files are called as usual except for the extension which should be .redir.
Example: SomeScreen Some.redir (contains this line: SomeOtherScree Some). This will register SomeScreen->Some graphic as a copy of SomeOtherScreen->Some graphic.

Every file can have a loader file associated by name. 
It is used to determine the class to use when loading the texture.
For example one can create a Animation like this: LoaderScreen AnimatingIcon_16x16.png / LoaderScreen AnimatingIcon.loader (contains this line: 'TMAnimatable') TMAnimatable is the class for loading animations.

Examples:
_MainMenu Background.png			--- Creates a Texture2D instance and loads it at game startup

_MainMenu AnimatingIcon_16x5.png		--- Together they create a Animation object 
_MainMenu AnimatingIcon.loader (TMAnimatable)   --- with 16 columns and 5 rows. That one is loaded at game startup.

SongPlay LifeBar Frame.png			--- Creates a simple Texture2D which will be loaded on demand

Same for Noteskins:
TapNote Down_8x8.png			--- Together they create a TapNote instance 
TapNote Down.loader (TapNote)		--- Which is a TMFramedTexture at the bottom level.

TapNote Up.redir (TapNote Down)		--- Make TapNote Up as copy of TapNote Down_8x8.png


The loader class should give a possibility to specify which resources are currently required so that it can preload them.
It also should provide a way to release unused resources by hand.
These two routines should be able to load all sub groups using one group path like this:

[themeLoader preLoad:@"SongPlay"]; 			--- Preloads all SongPlay stuff.
[themeLoader preLoad:@"MainMenu AnimatinIcon"];		--- Preloads the AnimatingIcon only.
[noteSkinLoader preLoad:@"TapNote"];			--- Preloads all TapNote objects.
[noteSkinLoader preLoadAll];				--- Load the whole noteskin into memory
[themeLoader unLoad:@"SongPlay"];			--- Release all SongPlay stuff (for example on song end).
[noteSkinLoader unLoadAll];				--- Release the noteskin.. for example if you changed the noteskin in options

All preloading/releasing routines should load/unload the textures to/from the GPU. This is done automatically by Texture2D though.
