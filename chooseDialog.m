function choice = chooseDialog

    d = dialog('Position',[300 300 250 150],'Name','Select One');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 80 210 40],...
           'String','Do you want to display results?');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[75 70 100 25],...
           'String',{'Yes';'No'});
           
       
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 25],...
           'String','ok',...
           'Callback',@popup_callback);
%            'Callback','delete(gcf)');
       
    % Wait for d to close before running to completion
    uiwait(d);
   
       function popup_callback(popup,event)
          idx = popup.Value;
          popup_items = popup.String;
          % This code uses dot notation to get properties.
          % Dot notation runs in R2014b and later.
          % For R2014a and earlier:
          % idx = get(popup,'Value');
          % popup_items = get(popup,'String');
          if idx == 1
                choice = 1;
          elseif idx == 2
              choice = 0;
          end
          close(d)
       end
end