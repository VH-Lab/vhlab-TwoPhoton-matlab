function closefigs
% Closes all figure windows except main TP analysis windows
% (twophotonbulkload and analyzetpstack).
% 
% GS



hands   = get (0,'Children');   % locate all open figure handles
for i=1:length(hands)
    if strcmp(get(hands(i),'Tag'),'twophotonbulkload') | strcmp(get(hands(i),'Tag'),'analyzetpstack')
        a=1;
    else
        close(hands(i))
    end
end

