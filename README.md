# ca_transients


This MATLAB script automatically fits exponential curves to an exponential or biexponential fit. Run the script in MATLAB and select your excel or .csv file with the data. The data should be two columnes - one with the tiem (starting from 0) and the other with the signal. 

Parameters to change include the following: 
f1 - Lowpass frequency cutoff for the Butterworth filter. 
fs - Sampling Frequency 
Npeaks - Number of peaks in the signal 
MinPeakDistance - Number of samples between peaks (minimum) 

I am working on writing this as a MATLAB function and will commit new changes to the script shortly. 
