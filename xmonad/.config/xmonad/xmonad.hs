--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

-- IMPORTS
import XMonad
import Data.Monoid
import System.Exit
import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Hooks.ManageDocks (docks, avoidStruts, docksStartupHook, manageDocks) 
import XMonad.Hooks.DynamicLog (xmobarStrip, dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
import Data.Maybe (fromJust)
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Config.Desktop
import XMonad.Layout.Gaps
import XMonad.Hooks.InsertPosition (insertPosition, Focus(Newer), Position(End))
import XMonad.Layout.Spacing
import XMonad.Layout.LayoutModifier
import XMonad.Layout.NoBorders
import XMonad.ManageHook
import XMonad.Util.NamedScratchpad

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
-- myTerminal      = "st"
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod1Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
-- 
-- myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
myWorkspaces = clickable . map xmobarEscape
               -- $ [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
               $ ["\xf303 ", "\xf269 ", "\xf120 ", "\xf10c ", "\xf10c ", "\xf10c ", "\xf10c ", "\xfa00 ", "\xf1bc "]
  where
        clickable l = [ "<action=xdotool key alt+" ++ show n ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]
--
-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#1e1e1e"
myFocusedBorderColor = "#FF79C6"

--
-- Named scratchpads
--
myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "zsh" spawnTerm findTerm manageTerm,
                  NS "gotop" spawnTop findTop manageTop
                 ]
  where
    spawnTerm  = myTerminal ++ "-e zsh"
    findTerm   = title =? "terminal"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
	         h = 0.9
		 w = 0.9
		 t = 0.95 -h
		 l = 0.95 -w

    spawnTop   = myTerminal ++ "-e gotop"
    findTop    = title =? "goTop"
    manageTop  = customFloating $ W.RationalRect l t w h
               where
	         h = 0.9
		 w = 0.9
		 t = 0.95 -h
		 l = 0.95 -w

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_space     ), spawn "j4-dmenu-desktop --dmenu='dmenu -c -l 15 -h 24' ")

    -- launch dmenu_run
    , ((modm .|. shiftMask, xK_space     ), spawn "dmenu_run -c -l 15 -h 24 ")
    -- launch "zsh" scratchpad
    , ((modm,               xK_y         ), namedScratchpadAction myScratchPads "zsh")
    
    -- launch "gotop" scratchpad
    , ((modm,               xK_x         ), namedScratchpadAction myScratchPads "gotop")

    -- open bookmark
    --, ((modm, xK_b     ), spawn "dmenu_run -c -l 15 -h 24 ")

    -- create bookmark
    --, ((modm .|. shiftMask, xK_b     ), spawn "dmenu_run -c -l 15 -h 24 ")

    -- close focused window
    , ((modm, xK_q     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_less), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_less ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask,xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_c     ), spawn "/home/finn/.local/bin/xmonad --recompile; /home/finn/.local/bin/xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.xmobarEscape :: String -> String xmobarEscape = concatMap doubleLts   where         doubleLts '<' = "<<"         doubleLts x   = [x] myWorkspaces :: [String] myWorkspaces = clickable . map xmobarEscape                $ ["dev", "www", "sys", "doc", "vbox", "chat", "mus", "vid", "gfx"]   where         clickable l = [ "<action=xdotool key super+" ++ show n ++ ">" ++ ws ++ "</action>" |                       (i,ws) <- zip [1..9] l,                       let n = i ]
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
--
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a 
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

myLayout = avoidStruts (tiled ||| Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = mySpacing 6 $ smartBorders $ Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
    [ insertPosition End Newer -- open new windows at the end 
    , title =? "Mozilla Firefox"    --> doShift ( myWorkspaces !! 1)
    , className =? "spotify"        --> doShift ( myWorkspaces !! 8)
    , className =? "signal"         --> doShift ( myWorkspaces !! 7)
    , className =? "discord"        --> doShift ( myWorkspaces !! 7)
    , className =? "mpv"            --> doShift ( myWorkspaces !! 8)
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ] <+> namedScratchpadManageHook myScratchPads

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-c.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
-- myStartupHook = return ()
myStartupHook = do
        --spawnOnce "unclutter &"
        --spawnOnce "feh --bg-fill '/home/finn/.config/wallpaper/wall.jpg' &"
        --spawnOnce "picom --experimental-backends &"
        --spawnOnce "sxhkd &" --temporary
        spawnOnce "/home/finn/.local/bin/startup &"
        setWMName "LG3D"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
      -- launch xmobar
        xmproc <- spawnPipe "xmobar -x 0 /home/finn/.config/xmobar/xmobarrc"
        xmonad $ docks $  ewmhFullscreen . ewmh $ desktopConfig
        --xmonad $ docks $  ewmh $ desktopConfig
           {
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        --layoutHook         = spacingRaw True (Border 0 10 10 10) True (Border 10 10 10 10) True $ layoutHook def,
        layoutHook         = myLayout,
        logHook            = workspaceHistoryHook <+> myLogHook <+> dynamicLogWithPP xmobarPP
	{ 
	  ppOutput          = \x -> hPutStrLn xmproc x 		      --xmobar on monitor 1
	, ppCurrent         = xmobarColor "#50FA7B" "" . wrap "[ " " ]" --current workspace in xmobar
	, ppVisible         = xmobarColor "#8BE9FD" "" . wrap "  " "  "		      --visible but not current workspace
	, ppHidden          = xmobarColor "#FF92D0" "" . wrap " ??" "  "  --hidden workspaces in xmobar
	, ppHiddenNoWindows = xmobarColor "#8BE9FD" "" . wrap "  " "  "               --hidden workspaces (no windows)
	, ppTitle           = xmobarColor "#50FA7B" "" . shorten 60 --title of active window in xmobar
	, ppSep             = "<fc=#E6E6E6> <fn=1>|</fn> </fc>"       --seperator in xmobar
	, ppUrgent          = xmobarColor "#FF5555" "" . wrap "!" "!" --urgent workspace
	, ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
	},
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
