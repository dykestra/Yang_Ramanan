
Information
===========

This is an implementation of the human pose estimation algorithm described in [1]. It includes pre-trained full-body and upper-body models. Much of the detection code is built on top of part-based model implementation of [2]. The training code implements a quadratic program (QP) solver described in [3].

To illustrate the use of the training code, this package also images from the PARSE image dataset [4], the BUFFY image dataset [5], and negative images from the INRIAPerson dataset [6]. We use also include the PCP evaluation code from [5] for benchmark evaluation on both datasets. The original evaluation code assumes a rigid-template detector, and we make modifications for our deformable skeleton detector.

Compatibility issues: The training code requires a large amount of memory (6GB). Uncomment/comment line 33/34 in code-full/learning/train.m to use less memory at the cost of longer training times.

Acknowledgements: We graciously thank the authors of the previous code releases and image benchmarks for making them publically available.

References
==========

[1] Y. Yang, D. Ramanan. Articulated Pose Estimation using Flexible Mixtures of Parts. CVPR 2011.

[2] P. Felzenszwalb, R. Girshick, D. McAllester. Discriminatively Trained Deformable Part Models. http://people.cs.uchicago.edu/~pff/latent.

[3] D. Ramanan. Dual Coordinate Descent Solvers for Large Structured Prediction Problems. UCI Technical Report, to appear.

[4] D. Ramanan. Learning to Parse Images of Articulated Bodies. NIPS 2006.

[5] V. Ferrari, Marcin Eichner, M. J. Marin-Jimenez, A. Zisserman. Buffy Stickmen V2.1: Annotated data and evaluation routines for 2D human pose estimation. http://www.robots.ox.ac.uk/~vgg/data/stickmen/index.html

[6] N. Dalal, B. Triggs. Histograms of Oriented Gradients for Human Detection. CVPR 2005.


Using the detection code
========================

1. Move to the code-basic directory
2. Start matlab
3. Run the 'compile' script to compile the helper functions.
   (you may need to edit compile.m to use a different convolution 
    routine depending on your system)
4. Run 'demo' to see an example of the code run on sample images.
5. By default, the code is set to output the highest-scoring detection
   in an image. Uncomment line 27 if you would like to see all detections.

Using the learning code
=======================

1. Move to the code-full directory
2. Start matlab
3. Run the 'compile' script to compile the helper functions.
   (you may need to edit compile.m to use a different convolution 
    routine depending on your system)
4. Run 'PARSE_demo' or 'BUFFY_demo' to see an example of the complete system, including training and benchmark evaluation.

Version Update
=======================

pose-release-v1.3
1. New convolution and other necessary files for windows machine to run our program.
2. New PCK and APK benchmarks, delete the old PCP criteria.
3. New functions for getting the highest score detection with overlap requirement.
4. First iteration joint training uses fixed mixture labels.
5. New visualization functions for showing the highest score detection and multiple detections.
6. New training code.
7. New non-maximum suppression after detection.

pose-release-v1.2
First time release
