disp('Requesting data from internet')
result=webread('https://data.humdata.org/hxlproxy/api/data-preview.csv?url=https%3A%2F%2Fraw.githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmaster%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftime_series_covid19_confirmed_global.csv&filename=time_series_covid19_confirmed_global.csv','options','table');
disp('Data recieved')
result1=result(1,:);
result(1,:)=[];
result=sortrows(result,2);
result=[result1;result];
shape1=size(result);
country=result(2:end,2);
height1=height(country);
dummy6=0;
disp('Loading country list')
for n=1:height1-1
    v=string(table2array(country(n,1)));
    for m=n+1:height1
        c=string(table2array(country(m,1)));
        if v==c
            r(dummy6+1)=m;
            dummy6=dummy6+1;
        end
    end
end
disp('All country loaded')
country(r,:)=[]
country=table2cell(country);
countrynum=length(country);
state=0;
countgood1=1;
countgooddummy1=1;
countgood2=1;
countgooddummy2=1;
countgood3=1;
countgooddummy3=1;
countrecovered3=1;
countcountrygood=1;
countcountrybad=1;
countcountrysame=1;
countcountryrecovered=1;
countsuddenbad3=1;
getting_good={};
getting_bad={};
same_situation={};
recovered={};
rowsgood1=[];
rowsgood2=[];
rowsgood3=[];
rowsrecovered3=[];
rowssuddenbad3=[];
disp('Analyzing all country')
for n=1:countrynum
    for i=2:shape1(1,1)
        if state==0 && country(n)==string(table2array(result(i,2)))
                country1=i;
                dummy1=i;
                state=state+1;
        elseif country(n)==string(table2array(result(i,2)))
               dummy2=i;
               state=state+1;    
        end
    end
    if state>1
        for m=5:shape1(1,2)
            dummy3=char(string(sum(str2double(table2array(result(dummy1:dummy2,m))))));
            result(dummy1,m)={dummy3};
        end
    end
    increment=6;
    loopcount=floor((shape1(1,2)-5)/6);
    date=(shape1(1,2)-loopcount*increment)-increment;
    for i=1:loopcount
        date=date+increment;
        newcasesinaweek=str2double(table2array(result(country1,date:date+increment)));
        totalcasesinaweek(1,i)=newcasesinaweek(7)-newcasesinaweek(1);
        averagenewcasesinaweek(1,i)=(newcasesinaweek(7)-newcasesinaweek(1))/7;
    end
    length2=length(totalcasesinaweek);
    for i=1:length2-1
        dummy4=totalcasesinaweek(i)+totalcasesinaweek(i+1);
        totalcasesinaweek(i+1)=dummy4;
    end
    if n==1
      period=date+increment;
    end
    indicator1=country{n};
    length3=length(averagenewcasesinaweek);
    growthratetoday=averagenewcasesinaweek(length3)/averagenewcasesinaweek(length3-1);
    growthratedisplay=append('Case Growth Rate(Today) in ',indicator1);
    %disp(growthratedisplay)
    %disp(growthratetoday)
    growthrateyesterday=averagenewcasesinaweek(length3-1)/averagenewcasesinaweek(length3-2);
    growthratedisplay=append('Case Growth Rate(Yesterday) in ',indicator1);
    %disp(growthratedisplay)
    %disp(growthrateyesterday)
    growthrateereyesterday=averagenewcasesinaweek(length3-2)/averagenewcasesinaweek(length3-3);
    growthratedisplay=append('Case Growth Rate(Ereyesterday) in ',indicator1);
    %disp(growthratedisplay)
    %disp(growthrateereyesterday)
    if growthratetoday<growthrateyesterday && growthrateyesterday<growthrateereyesterday
        situationdisplay1=append('\nSituation is getting good in ',indicator1);
        situationdisplay1=append(situationdisplay1,'\n');
        %fprintf(2,situationdisplay1)
        getting_good(countcountrygood,1)=append(country(n),append(' - Growth Rate = ',num2str(growthratetoday)));
        countcountrygood=countcountrygood+1;
        if growthratetoday<=1
           rowsgood1(countgood1)=countgooddummy1;
           countgood1=countgood1+1;
        end
        countgooddummy1=countgooddummy1+1; 
    elseif growthratetoday>growthrateyesterday && growthrateyesterday>growthrateereyesterday
        situationdisplay2=append('\nSituation is getting bad in ',indicator1);
        situationdisplay2=append(situationdisplay2,'\n');
        %fprintf(2,situationdisplay2)
        getting_bad(countcountrybad,1)=append(country(n),append(' - Growth Rate = ',num2str(growthratetoday)));
        countcountrybad=countcountrybad+1;
        if growthratetoday<=1
           rowsgood2(countgood2)=countgooddummy2;
           countgood2=countgood2+1;
        end
        countgooddummy2=countgooddummy2+1;
    elseif ismissing(growthratetoday)
           situationdisplay3=append('\nNo one infected in ',indicator1);
           situationdisplay3=append(situationdisplay3,'\n');
           %fprintf(2,situationdisplay3)
           recovered(countcountryrecovered,1)=append(country(n),append(' - Growth Rate = ',num2str(growthratetoday)));
           countcountryrecovered=countcountryrecovered+1;
    else
        situationdisplay4=append('\nSituation is same as previous in ',indicator1);
        situationdisplay4=append(situationdisplay4,'\n');
        %fprintf(2,situationdisplay4)
        same_situation(countcountrysame,1)=append(country(n),append(' - Growth Rate = ',num2str(growthratetoday)));
        countcountrysame=countcountrysame+1;
        if growthratetoday<=1
           rowsgood3(countgood3)=countgooddummy3;
           countgood3=countgood3+1;
        elseif growthratetoday>=2 && growthrateyesterday<=1 && growthrateereyesterday<=1 && growthratetoday~=inf 
               rowssuddenbad3(countsuddenbad3)=countgooddummy3;
               countsuddenbad3=countsuddenbad3+1;
        end
        countgooddummy3=countgooddummy3+1;
    end
    state=0;
end
if length(getting_good)>=length(getting_bad) && length(getting_good)>=length(same_situation) && length(getting_good)>=length(recovered)
    longestarray=length(getting_good);
elseif length(getting_bad)>=length(same_situation) && length(getting_bad)>=length(recovered)
    longestarray=length(getting_bad);
elseif length(same_situation)>=length(recovered)
    longestarray=length(same_situation);
else
    longestarray=length(recovered);
end
dummy5={getting_good,getting_bad,same_situation,recovered};
for i=1:4
    if length(dummy5{i})<longestarray
       emptyrows=longestarray-length(dummy5{i});
       emptyvalue=num2cell(nan(emptyrows,1));
       if i==1
           getting_good=[getting_good;emptyvalue];
       elseif i==2
           getting_bad=[getting_bad;emptyvalue];
       elseif i==3
           same_situation=[same_situation;emptyvalue];
       else
           recovered=[recovered;emptyvalue];
       end
    end
end
disp('Analysis done')
disp('Result is loading in table')
situationtable=table(getting_good,getting_bad,same_situation,recovered);
fig = uifigure;
uit = uitable(fig,'Data',situationtable);
s1 = uistyle('BackgroundColor','green');
s2 = uistyle('BackgroundColor','red','FontColor','white');

if ~isempty(rowsgood1)
    length4=length(rowsgood1);
    columngood1=ones(1,length4);
    addStyle(uit,s1,'cell',[rowsgood1',columngood1']);
end


if ~isempty(rowsgood2)
    length5=length(rowsgood2);
    columngood2=2*ones(1,length5);
    addStyle(uit,s1,'cell',[rowsgood2',columngood2']);
end


if ~isempty(rowsgood3)
    length6=length(rowsgood3);
    columngood3=3*ones(1,length6);
    addStyle(uit,s1,'cell',[rowsgood3',columngood3']);
end


if ~isempty(rowssuddenbad3)
    length7=length(rowssuddenbad3);
    columngood3=3*ones(1,length7);
    addStyle(uit,s2,'cell',[rowssuddenbad3',columngood3']);
end


disp('If a cell turns green which indicates that the infection rate is decreasing')
disp('If a cell turns red which indicates that previously the infection rate was decreasing now suddenly it is increasing badly')
timeindicator1=table2array(result(1,period));
timeindicator2='Last Updated: ';
timeindicator=append(timeindicator2,timeindicator1);
disp(timeindicator)