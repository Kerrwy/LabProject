Matlab codes for the paper:

"Feedforward Categorization on AER Motion Events using Cortex©\like
Features in a Spiking Neural Network"


Top Files:


top_onPosture.m

    (performance evaluation on posture dataset. 80% for traning, the others for testing.)



top_onPosture_runAllTstIn1Stream.m

    Combine all testing data into one event stream, evaluate the system on this event stream.



top_onMNIST.m

    (performance evaluation on MNIST dataset. 60000 for traning, 10000 for testing.)



top_onMNIST_DVS.m

    (performance evaluation on MNIST DVS dataset. Totally 10000 samples. 90% training, 10% test)
    (Each sample lasts about 200 ms.)



IMPORTANT NOTES:

(1) This code automatically utilize the "MATLAB coder" to build "edTempotronCore.m" into two separate MEX files, one for training and the other for test. Using MEX greatly increase the speed of tempotron classifier. Before you run this code, make sure you have the MEX environment properly configured. (mex -setup)

The feature extraction part (Convolution and MAX operation) is still in pure MATLAB codes and it runs pretty slow. 

(2) Before you run this code, download the following three MATLAB data (.mat) files from the link below and put these files into the same folder as the source (.m) files.

posture_2timesIn1CIN_32x32.mat
MNIST_blackBg_60000train_10000test.mat
MNIST_DVS_28x28_10000_200ms.mat

https://onedrive.live.com/redir?resid=BDEE9C592BBE7CE8!959&authkey=!ACJzKiCFroYO7po&ithint=folder%2cmat

or 

https://www.dropbox.com/sh/0tvd1lkl2uhamhe/AADb2ylm9zSNxNzzhSL6DjbAa

These mat files are the input data to our algorithm. If none of the above links work, please contact Bo ZHAO by email zhaob@i2r.a-star.edu.sg




