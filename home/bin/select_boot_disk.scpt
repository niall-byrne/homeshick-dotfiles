on run argv
    set selected_partition to (item 1 of argv)
    tell application "System Events"
        try
            tell application "System Preferences"
                set current pane to pane id "com.apple.preference.startupdisk"
                activate
            end tell
            tell application process "System Preferences"
                delay 0.3
                tell window "Startup Disk"
                    set lockFound to false
                    repeat with x from 1 to number of buttons
                        if lockFound is false then
                            if title of button x is "Click the lock to make changes." then
                                click button x
                                set lockFound to true
                                repeat while title of button x is "Authenticating..."
                                    delay 1
                                end repeat
                            else if title of button x is "Click the lock to prevent further changes." then
                                set lockFound to true
                            end if
                        end if
                    end repeat
                    click radio button (selected_partition) of radio group 1 of scroll area 1 of group 1 of splitter group 1
                    delay 0.4
                    click button "Restart…"
                    delay 0.3
                    click button "Restart" of sheet 1
                    return true
                end tell
            end tell
        on error
            delay 0.5
            tell application "System Preferences"
                if current pane is pane id "com.apple.preference.startupdisk" then quit
            end tell
            return false
        end try
    end tell
end run