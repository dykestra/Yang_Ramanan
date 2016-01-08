Buffy stickmen V 3.0
==================== 

M. Eichner, M. J. Marin-Jimenez, V. Ferrari and A. Zisserman 



Introduction 
~~~~~~~~~~~~ 

2D Human Pose estimation is a very interesting problem for which only few  
common datasets with ground-truth annotation exist.  
We release here an uncontrolled dataset with associated ground-truth stickmen annotations.  
The data comes from the TV show Buffy the Vampire Slayer and it is very challenging:  
persons appear at a variety of scales, against highly cluttered background, and wear any  
kind of clothing.  
For each imaged person, we provide line segments indicating location, size and orientation of six body parts  
(head, torso, upper/lower right/left arms).  
In each annotated frame exactly one person is annotated.  
The packages includes a total of 748 annotated video frames over 5 episodes of the fifth season of BTVS.  
The results on three episodes from this dataset (276 frames) are published in [1,2,3,4,6].  

The current release contains the results published in [6], based on the better upper-body detector [7] (as opposed to the old one [5], which we used in [1,2,3,4]). The new detector yields 95% detection rate on the test set, which enables to evaluate pose estimation performance on a greater coverage of the test set.

For reference we still include results published in [4] based on the old upper body detector [5]. These results are now obsolete and shall not be used.  



Contents 
~~~~~~~~ 

This package contains: 
  - raw image frames from BTVS 
  - corresponding ground-truth stickmen annotations (referred to as 'GT stickmen' from now on) 
  - matlab code to read-in and visualize GT stickmen 
  - matlab code to evaluate stickmen estimated by an algorithm against GT stickmen 

  - human pose estimation results from [6]  
    (i.e. all stickmen estimated by [6], along with the detection windows from [7]).  
  - PCP performance curves 


Let «dir_root» be the directory where this package was uncompressed. 
The resulting sub-directories contain: 

 «dir_root»/data - one annotation text file per episode, for a total of 748 frames with one GT stickman each, 

 «dir_root»/code - Matlab code to read, display and evaluate annotations 

 «dir_root»/images 
                |--- buffy_s5e2_original : images from episode 2 
                |--- buffy_s5e3_original : images from episode 3 
                |--- buffy_s5e4_original : images from episode 4  
                |--- buffy_s5e5_original : images from episode 5  
                |--- buffy_s5e6_original : images from episode 6 

 «dir_root»/overlays 
                |--- buffy_s5e2_withoverlays : images from episode 2 with stickmen overlays 
                |--- buffy_s5e3_withoverlays : images from episode 3 with stickmen overlays 
                |--- buffy_s5e4_withoverlays : images from episode 4 with stickmen overlays  
                |--- buffy_s5e5_withoverlays : images from episode 5 with stickmen overlays 
                |--- buffy_s5e6_withoverlays : images from episode 6 with stickmen overlays   
                these overlay images are useful for rapidly surfing the dataset, and for double checking 
                whether you have read the annotation text files correctly. 



Quick start 
~~~~~~~~~~~ 

You can follow the next steps to check that everything is properly set: 

1) start matlab 

2) navigate to «dir_root»/code (e.g. by using cd command) 
    
3) execute command: startup 
   This will add necessary paths to your matlab environment 

4) if this is the first time you run the code, then execute installmex. 
   This will compile the mex-files for your system. 

5) execute the following to display the GT stickman from the first annotated frame 
   in episode 2: 
    img = imread('000063.jpg'); 
    lF = ReadStickmenAnnotationTxt('../data/buffy_s5e2_sticks.txt'); 
    hdl = DrawStickman(lF(1).stickmen.coor, img); 

   check that a new figure is now open and it shows the same as the file 
   '«dir_root»/code/000063_stickman.jpg' 

6) execute the following commands to recompute our best result from [4]: 

    % loading ground-truth annotations for episodes s5e2 s5e5 s5e6 
    gt2 = ReadStickmenAnnotationTxt('../data/buffy_s5e2_sticks.txt','episode','2'); 
    gt5 = ReadStickmenAnnotationTxt('../data/buffy_s5e5_sticks.txt','episode','5'); 
    gt6 = ReadStickmenAnnotationTxt('../data/buffy_s5e6_sticks.txt','episode','6'); 
    % concatenating ground-truth stickmen 
    GTALL = [gt2(:); gt5(:); gt6(:)]'; 
    % loading stickmen for the evaluation 
    load('../techrep2010_buffy_results.mat'); 
    % evaluating [6]  
    [detRate PCP] = BatchEval(@detBBFromStickmanBuffy,@EvalStickmen,techrep2010_buffy,GTALL) 

   You should obtain the following results: detRate = 0.9529, PCP = 0.8327. 

7) if all points above went well, this package is working perfectly. 

8) reproducing our PCP curve  

   calcPCPcurve(@detBBFromStickmanBuffy,@EvalStickmen,techrep2010_buffy,GTALL,[],true); 


    
Description of the annotation files 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

Each text file in «dir_root»/data contains annotations for an episode in the format: 

«frame_number_i» 
 «x11»  «y11» «x12» «y12» 
 «x21»  «y21» «x22» «y22»  
 «x31»  «y31» «x32» «y32»  
 «x41»  «y41» «x42» «y42»  
 «x51»  «y51» «x52» «y52»  
 «x61»  «y61» «x62» «y62»   
«frame_number_i+1» 
 «x11»  «y11» «x12» «y12» 
 «x21»  «y21» «x22» «y22»  
 «x31»  «y31» «x32» «y32»  
 «x41»  «y41» «x42» «y42»  
 «x51»  «y51» «x52» «y52»  
 «x61»  «y61» «x62» «y62»   
 . . . 
 . . . 

where: 
 - «frame_number_i» is the frame number of the i-th annotated frame 
   (you can check the corresponding image in: «dir_root»/images/buffy_s5e[episode_number]_withoverlays). 
 - «xsp» is coordinate x for segment s (from 1 to 6) and end point p (1 or 2), 
   the order of the segments corresponds to torso, left upper arm, right upper arm, 
   left lower arm, right lower arm and head respectively ('left' and 'right' as they appear in the image). 



Matlab code 
~~~~~~~~~~~ 

The following Matlab functions are provided: 
 - ReadStickmenAnnotationTxt: reads an annotation file 
 - DrawStickman: draws annotation for a single frame 
 - DirectEvalStickman: directly evaluate one estimated stickman against one GT stickman 
 - EvalStickmen: evaluate all estimated stickmen for an image against the one GT stickman for that image 
 - BatchEvalBuffy: evaluate multiple images 
 - DummyBuffyPoseEstimationPipeline: dummy pose estimation routine that outputs data in the format required by BatchEvalBuffy 


The following Matlab functions are provided: 
 - ReadStickmenAnnotationTxt: reads an annotation file 
 - DrawStickman: draws annotation for a single image 
 - DirectEvalStickman: directly evaluates one estimated stickman against one GT stickman 
 - EvalStickmen: evaluates all estimated stickmen for an image against the one GT stickman for that image 
 - BatchEval: evaluates over an image set for a fixed pose estimation accuracy threshold  
 - calcPCPcurve: evaluates over an image set for a range of pose estimation accuracy thresholds (produces a PCP performance curve)  
 - DummyBuffyPoseEstimationPipeline: dummy pose estimation routine that outputs data in the format required by BatchEval  


For exact input/output arguments format please type: help «function_name» 



Evaluation criterion [4,6] 
~~~~~~~~~~~~~~~~~~~~~~~~~~

For each image, BatchEval expects your system to provide a set of detected persons. Each detected person consists of an estimated window around the head and shoulders, as well as an estimated stickman. If you only provide the stickman, BatchEval will estimate such a window for you. 

Given this information, BatchEval will compute two numbers: 

a) Detection rate 
indicates how many of the GT stickmen have been detected. 
A GT stickmen is counted as detected if a window E estimated by your system overlaps more than 50% with the GT window G automatically derived from the GT stickman. The overlap measure is the area of intersection divided by the area of union between E and G. This is the PASCAL VOC criterion [5].  

b) PCP (Percentage of Correctly estimated body Parts) 
an estimated body part is counted as correct if its segment endpoints lie within t% of the length of the ground-truth segment from their annotated location. PCP is evaluated only for stickmen that have been detected (i.e. there is a correct detection window in the sense of point a). Overall performance is evaluated by a PCP-curve, obtained by varying the accuracy threshold t (calcPCPcurve.m). If you want to report a single number, then we recommend taking PCP at t=20% (strict) or t=50% (tolerant, this is the setting of BatchEval.m by default). 

The ground-truth images contain exactly one ground-truth stickman each. Your system may detect multiple people in an image and therefore produce multiple estimated stickmen. BatchEval will automatically select the one matching with the GT stickman(i.e. the one whose detection window is correct), if there is one. If your system outputs multiple detections on the same person BatchEval will throw an error (this is invalid behavior in our protocol). 

This evaluation protocol used in [6] is a stricter version of the one used in [4]. It is designed to prevent users from artificially achieving higher PCP scores by outputting multiple estimated stickman per person. The protocol in [4] allowed for multiple detections of the same person and counted the PCP of the highest scoring one. This is now banned from the official protocol. If you want to publish a comparison to our work, please cite our latest results from [6]. 

To obtain the total PCP over the whole test set, not only over persons with a correct detection window, please multiply PCP by the detection rate (i.e. multiple the two numbers output by BatchEval). 



Performance of [6]  
~~~~~~~~~~~~~~~~~~  

For convenience we provide a figure containing PCP performance curves for our method in [6] in PNG format («dir_root»/PCP_techrep2010_buffy.png) and as a Matlab figure («dir_root»/PCP_techrep2010_buffy.fig). 
The curve was obtained by varying the accuracy threshold t (as discussed above). The PCP curve allows to observe how well a system does as the threshold t gets tighter, i.e. only more and more accurate pose estimates are accepted. You can reproduce this curve with the calcPCPcurve routine (which loops over BatchEval for a range of thresholds t).  

For reference we still provide figures with results from [4] ( PCP_bmvc09_cvpr09_cvpr08_buffy_vgg-upper-body-detector(old).*), but they are now obsolete and shall not be used. 



Results of [6]  
~~~~~~~~~~~~~~  

We also provide data structure containing our results from [6]. It is stored in this mat-file:  

«dir_root»/techrep2010_buffy_results.mat 

Load it in Matlab (version 7 or later) by executing this command:  

load('«dir_root»/techrep2010_buffy_results.mat')  

Results are provided for our best system from [6]:  

techrep2010_ethzpascal: (1x549 struct)  
    .filename: image filename  
    .stickmen: (1xD struct) of results for .filename (D = number of detection windows in this image)  
        .coor: 4x6 array of sticks coordinates in the same order as GT (see above)  
        .det: [minx miny maxx maxy] coordinates of the detection window  

This data can be used to reproduce our performance curve (using the calcPCPcurve routine). The detection windows were obtained using the Calvin upper-body detector [7]. You might want to use these detection windows as an input to your own human pose estimator, to ensure an exact comparison to [6] in terms of PCP.

For reference we still provide results from [4] («dir_root»/BMVC09best256_buffy_results.mat) based on the old vgg upper-body detector [5], but they are now obsolete and shall not be used. 



Pose estimation prototype routine 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

This package includes a dummy pose estimation routine (DummyBuffyPoseEstimationPipeline) that 
outputs data in the format required by BatchEvalBuffy. This is included to demonstrate how to produce 
data formatted for BatchEvalBuffy. 
To fully understand the structure of this input data, we recommend you look into the techrep2010_buffy variable: 

% example use: 
d2 = DummyBuffyPoseEstimationPipeline('../images/buffy_s5e2_original',2); 
d5 = DummyBuffyPoseEstimationPipeline('../images/buffy_s5e5_original',5); 
d6 = DummyBuffyPoseEstimationPipeline('../images/buffy_s5e6_original',6); 
Dummy = [d2 d5 d6]; 
[detRate PCP] = BatchEval(@detBBFromStickmanBuffy,@EvalStickmen,Dummy,GTALL) 

this will produce some low random values (around 5-10%) for both detRate and PCP. 



Support 
~~~~~~~ 

For any query/suggestion/complaint or simply to say you like/use the annotation and software just drop us an email 

eichner@vision.ee.ethz.ch 
ferrari@vision.ee.ethz.ch 
mjmarin@uco.es 
az@robots.ox.ac.uk 



References 
~~~~~~~~~~ 

[1] Progressive search space reduction for pose estimation 
Vittorio Ferrari, M.J. Marin-Jimenez and Andrew Zisserman 
Proceedings of IEEE Conference in Computer Vision and Pattern Recognition, June 2008. 

[2] 2D Human Pose Estimation in TV Shows 
Vittorio Ferrari, M.J. Marin-Jimenez and Andrew Zisserman 
International Dagstuhl Seminar, Dagstuhl, Germany, July 2008

[3] Pose search: retrieving people using their pose 
Vittorio Ferrari, M.J. Marin-Jimenez and Andrew Zisserman 
Proceedings of IEEE Conference in Computer Vision and Pattern Recognition, June 2009. 

[4] Better appearance models for pictorial structures 
Marcin Eichner and Vittorio Ferrari 
British Machine Vision Conference, September 2009. 

[5] http://www.robots.ox.ac.uk/~vgg/software/UpperBody/index.html 

[6] Articulated Human Pose Estimation and Search in (Almost) Unconstrained Still Images  
M.Eichner, M. Marin-Jimenez, A. Zisserman, V.Ferrari  
ETH Technical Report, September 2010. 

[7] Calvin upper-body detector   
http://www.vision.ee.ethz.ch/~calvin/calvin_upperbody_detector/  



Version History 
~~~~~~~~~~~~~~~  

Version V 3.0
-------------
- include new detection windows from the Calvin upper-body detector, covering 95% of the test images

- pose estimation results updated to [6]

- evaluation framework interface updated


Version 2.1 
----------- 
- updated ReadStickmenAnnotationTxt to match the format of the PASCAL stickmen dataset 

- fixed BatchEvalBuffy to really forbid multiple stickmen on the same person (as described above) 


Version 2.0 
----------- 
- added PCP performance curves 

- added episode 3, including 376 new annotated frames 

- matlab evaluation routines  

- pose estimation results presented in [4] and the upper body detections used in [1,2,3,4] 

- coordinates order in the annotations changed from: 
  «x1» «x2» «y1» «y2» 
  to 
  «x1» «y1» «x2» «y2» 
  accompanied by corresponding changes in DrawStickman and ReadStickmenAnnotationTxt routines 

- episodes 2,5,6 include exactly the 276 annotated frames used in [1,2,3,4] 
  (release V1.0 had some extra frame that might have been confusing). 
  From now on, all 276 annotations from episodes 2,5,6 can be directly used for comparing to [1,2,3,4]. 


Version 1.0 
----------- 
- initial release
