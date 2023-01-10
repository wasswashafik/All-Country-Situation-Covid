result=webread('https://data.humdata.org/hxlproxy/api/data-preview.csv?url=https%3A%2F%2Fraw.githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmaster%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftime_series_covid19_confirmed_global.csv&filename=time_series_covid19_confirmed_global.csv','options','table');
result1=result(1,:);
result(1,:)=[];
result=sortrows(result,2);
result=[result1;result]
shape1=size(result);
country={'China','Italy','US','Germany','United Kingdom','India','Spain','Iran','Korea, South','France','Bangladesh','Pakistan','Qatar','Japan'};
countrynum=length(country);
state=0;
countcountrygood=1;
countcountrybad=1;
countcountrysame=1;
getting_good={};
getting_bad={};
same_situation={};
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
      figure('Position',[0 0 1920 1080])  
    end
    loglog(totalcasesinaweek,averagenewcasesinaweek,'linewidth',3)
    indicator1=country{n};
    indicator2='\leftarrow ';
    indicator=append(indicator2,indicator1);
    text(totalcasesinaweek(loopcount),averagenewcasesinaweek(loopcount),indicator,'FontSize',12)
    hold on
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
        fprintf(2,situationdisplay1)
        getting_good(countcountrygood,1)=append(country(n),append(' - Growth Rate = ',num2str(growthratetoday)));
        countcountrygood=countcountrygood+1;
    elseif growthratetoday>growthrateyesterday && growthrateyesterday>growthrateereyesterday
        situationdisplay2=append('\nSituation is getting bad in ',indicator1);
        situationdisplay2=append(situationdisplay2,'\n');
        fprintf(2,situationdisplay2)
        getting_bad(countcountrybad,1)=append(country(n),append(' - Growth Rate = ',num2str(growthratetoday)));
        countcountrybad=countcountrybad+1;
    else
        situationdisplay3=append('\nSituation is same as previous in ',indicator1);
        situationdisplay3=append(situationdisplay3,'\n');
        fprintf(2,situationdisplay3)
        same_situation(countcountrysame,1)=append(country(n),append(' - Growth Rate = ',num2str(growthratetoday)));
        countcountrysame=countcountrysame+1;
    end
    state=0;
end
if length(getting_good)>=length(getting_bad) && length(getting_good)>=length(same_situation)
    longestarray=length(getting_good);
elseif length(getting_bad)>=length(same_situation)
    longestarray=length(getting_bad);
else
    longestarray=length(same_situation);
end
dummy5={getting_good,getting_bad,same_situation};
for i=1:3
    if length(dummy5{i})<longestarray
       emptyrows=longestarray-length(dummy5{i});
       emptyvalue=num2cell(nan(emptyrows,1));
       if i==1
           getting_good=[getting_good;emptyvalue];
       elseif i==2
           getting_bad=[getting_bad;emptyvalue];
       else
           same_situation=[same_situation;emptyvalue];
       end
    end
end
situationtable=table(getting_good,getting_bad,same_situation)
grid on
title('COVID 19 Country Analysis in log scale','FontSize', 24)
xlabel('Total Cases','FontSize', 20)
ylabel('Average New Cases','FontSize', 20)
timeindicator1=table2array(result(1,period));
timeindicator2='Last Updated: ';
timeindicator=append(timeindicator2,timeindicator1);
text(10^2,10^4,timeindicator,'FontSize',15)
legend(country,'Location','southeast')