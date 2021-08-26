% Ca_transient_analysis.m 

close all; 
clear;
clc; 
%% Data Preprocessing 
[filename, pathname] = uigetfile({'*.xlsx','Excel Files(*.xlsx)'; '*.txt','Txt Files(*.txt)'}, 'Pick a file');
A = xlsread(filename); 

t = A(:,1); 
x = A(:,2); 
t = t(~isnan(t)); 
x = x(~isnan(x)); 
x2 = abs(x); 
x2(abs(x2) > 100) = 100;

%% Signaling 

% comment out these lines if you want to filter 

f1 = 10; 
fs = 250; 
 
[b,a] = butter(2,f1/fs); 
xfilt = filter(b,a,x2);


%% Processing 

t1 = t; 
x1 = x; 
xfilt1 = xfilt; 

% find peak parameters 
Npeaks = 6;  % CHANGE THIS IF YOU NEED MORE PEAKS 
MinPeakDistance = 200;  % CHANGE THIS BASED ON FREQUENCY 

[pks,locs] = findpeaks(xfilt1,'MinPeakDistance',MinPeakDistance,'Npeaks',Npeaks,'MinPeakHeight',14); 
%[pks,locs] = findpeaks(xfilt1,'MinPeakDistance',MinPeakDistance,'Npeaks',Npeaks); 

figure;
hold on 
plot(t1,xfilt1,'LineWidth',2)
plot(t1(locs),pks,'o','MarkerSize',12)

Fmax_vec = zeros(size(locs)); 
F0_vec = zeros(size(locs)); 
fit_parms = zeros(size(locs)); 


entire_fit = cell(length(locs),1); 
all_time = []; 

mid_point = 100.*ones(7,1); 
mid_point(5,1) = 200; 
window = 50.*ones(7,1);
left_point = round(mid_point - window/2); 
right_point = round(mid_point + window/2); 
for aa = 1:length(locs)
    if aa == length(locs)
        ta = t1(locs(aa):end,1); 
        ya = xfilt1(locs(aa):end,1);
        F0_vec(aa) = mean(xfilt1(end-200:end)); 
        plot(t1(end-100),F0_vec(aa),'ko','MarkerSize',12)
        
    else 
        ta = t1(locs(aa):locs(aa+1)-mid_point(aa),1); 
        ya = xfilt1(locs(aa):locs(aa+1)-mid_point(aa),1); 
        F0_vec(aa) = mean(xfilt1(locs(aa+1)-right_point(aa):locs(aa+1)-left_point(aa),1)); 
        plot(t1(locs(aa+1)-mid_point(aa)),F0_vec(aa),'ko','MarkerSize',12)
    end 
    
    if (aa == length(locs) +1) % Get rid of the one here to run the bioexponential fit 
        my_exp_fit = @(parms,tdata) parms(5) + parms(1).*(exp(-(tdata-tdata(1))./parms(2))) + parms(3).*(exp(-(tdata-tdata(1))./parms(4))) - (parms(1) + parms(3));
        opts = optimset('Display','off');
        x0 = [1,1,1,1,pks(aa)]; % initialization 
        my_fit = lsqcurvefit(my_exp_fit,x0,ta,ya,[],[],opts); 
        
    else 
        my_exp_fit = @(parms,tdata) (pks(aa)-parms(2)).*(exp(-(tdata-tdata(1))./parms(1)))+parms(2); 
        opts = optimset('Display','off');
        x0 = [1,min(ya)]; % initialization 
        my_fit = lsqcurvefit(my_exp_fit,x0,ta,ya,[],[],opts); 
        
    end 
    
    

    % performing the fit 
    
    
    if (aa == length(locs))
        yfita = my_exp_fit(my_fit,ta); 
    else 
        yfita = my_exp_fit(my_fit,ta); 
    end 
    
    plot(ta,yfita,'r-','LineWidth',2) 
    
    Fmax_vec(aa) = pks(aa); 
 
    fit_parms(aa) = my_fit(1);
    entire_fit{aa,1} = [ta,yfita]; 
end 
hold off; 
Rsq = my_rsquared(ya,yfita); 
%tau1 = my_fit(2); 
%tau2 = my_fit(4); 
tau1 = my_fit(1); 

dF = Fmax_vec(end) - F0_vec(end-1); 
%out = [dF;tau1;tau2;Rsq];
out = [tau1;Rsq];

filtered_sig = [t1,xfilt1]; 
