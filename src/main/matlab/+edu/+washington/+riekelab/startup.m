% A Symphony startup script to enforce some lab conventions

options = symphonyui.app.Options.getDefault();
options.fileDefaultName = @()[datestr(now,'yyyy-mm-dd') '_' getenv('RIG_LETTER')];