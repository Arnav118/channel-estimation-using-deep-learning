# channel-estimation-using-deep-learning
Channel estimation for high speed trains , using OFDM and deep learning models like FSRCNN and DNCNN
Develop a deep learning approach for channel estimation inhigh-mobility scenarios like high-speed railways using areconstruction and recovery network model.Model will improve the accuracy and efficiency of channel estimation under non-stationary and fast time-varying wireless channel conditions.
FSRCNN (Fast Super-Resolution Convolutional Neural Network): 
1.Reconstructs a low-resolution (LR) image (pilot signals) into a high-resolution(HR) channel image by extracting features and performing interpolation.
DnCNN (Denoising Convolutional Neural Network): 
2.Refines the HR image by reducing noise and enhancing the channel estimation'sprecision.The combined architecture, named FSR-Dn, is trained offline using simulateddatasets generated in MATLAB.
