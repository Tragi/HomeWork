Home work - Personal Notes

1) Native application without any 3rd party FW - you can just build it as it is.
2) If you are running on simulator - there may be a bug on ios 13 simulator with UITextView/Filed.didBecomeActive what causing freeze of the simulator. To avoid it you can switch off Edit/Automatically Sync Pasteboard in simulator (https://forums.developer.apple.com/thread/122972).
3) Because of mockup API (apiary.io), there is option for offline mode - it is in core data only. There is no synchronisation between api and core data, because there is no way how to synchronise current api with core data and present basic CRUD operations properly.
4) Pattern is inspired from MVVM, And I wanted to present my personal pattern which present viewState. The logic is:
    Every single event (request did end, or user interaction, etc) is just change of state from initial state to target state.  ViewState itself basically represents what user wants, and dataSource output model, is what user get.

P.S. It is just one man-day of working, so it can be better, of course. But this is just demo version of my "skills" :)
