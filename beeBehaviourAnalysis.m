global casu_pos;
casu_pos = 4.5;

time = 500;
nBees = 10;
posD = randn(time, nBees);
posA = randn(time, nBees);
vel = randn(time, nBees);

Ts = [28, 28; 30, 28; 27, 32];
k = 1; 
trigger = 0;
T = [28, 28];
dT = 0.02;
Tr = Ts(1,:);

fi = figure(1);
grid on
axis([-10,10,-10,10])
str = 't = 0';
annotation('textbox',[0.7,0,1,0.9],'String',str,'FitBoxToText','on','Tag','time_tag');

mTextBox1 = uicontrol('style','text','Tag','textbox1');
mString1 = sprintf('T = %.2f', T(1));
set(mTextBox1,'String',mString1);
mTextBoxPosition1 = get(mTextBox1,'Position');
set(mTextBox1,'Position',[150,330,100,15]);

mTextBox2 = uicontrol('style','text','Tag','textbox2');
mString2 = sprintf('T = %.2f', T(2));
set(mTextBox2,'String',mString2);
mTextBoxPosition2 = get(mTextBox2,'Position');
set(mTextBox2,'Position',[350,330,100,15]);

for iTime = 1 : time-1
    if iTime == 100
        Tr = Ts(2,:);
    end
    if iTime == 300
        Tr = Ts(3,:);
    end
    
    for i = 1 : 2
        if T(i) ~= Tr(i)
            T(i) = T(i) + dT * sign(Tr(i) - T(i));
        end
    end

    
    [posD(iTime+1,:),posA(iTime+1,:),vel(iTime+1,:)] = beeSimulation...
        (posD(iTime,:),...
        posA(iTime,:),...
        vel(iTime,:),...
        T, ...
        1);

    delete(findall(fi,'Tag','time_tag'));
    str = sprintf('t = %.1f', (iTime));
    annotation('textbox',[0.7,0,1,0.9],'String',str,'FitBoxToText','on','Tag','time_tag');
    mString1 = sprintf('T = %.2f', T(1));
    m = findall(fi,'Tag','textbox1');
    set(m,'String',mString1);
    mString2 = sprintf('T = %.2f', T(2));
    m = findall(fi,'Tag','textbox2');
    set(m,'String',mString2);
    axis([-10,10,-10,10])
    pause(0.0005);

    if ~ishghandle(fi)
        close all
        break
    end

end