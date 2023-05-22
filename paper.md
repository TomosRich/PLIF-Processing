---
title: 'A Comprehensive Planar Laser Induced Fluorescence Software Package'
tags:
  - matlab
  - planar laser induced fluorescence
  - post-processing
  - aerodynamics
  - experimental
authors:
  - name: T. Rich
    orcid: 0000-0002-6259-4225
    equal-contrib: true
    affiliation: 1
    corresponding: true # (This is how to denote the corresponding author)
  - name: C. Vanderwel
    orcid: 0000-0002-6259-4225
    equal-contrib: true 
    affiliation: 1
  - name: E. Parkinson
    orcid: 0000-0002-6259-4225
    equal-contrib: true
    affiliation: 1
affiliations:
 - name: University of Southampton, United Kingdom
   index: 1
date: 22nd May 2023
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
aas-journal: Astrophysical Journal <- The name of the AAS journal.
---

# Statement of need

Optical measurement methods in fluid dynamics are an extensively used and understood field, there are several intrinsic advantages to this category of techniques. First of which is that they can be used to observe an entire plane of a flow at once, as opposed to techniques like hot wire annemometry, which take point measurements. Optical techniques are also non intrusive, and therefore exert little influence on the flow itself.

Planar Laser Induced Fluorescence (PLIF) is a technique used to quantitatively measure the concentration of a fluorescent species in a flow. This technique is a useful tool to calculate dispersive fluxes when combined with particle image velocimetry, and can provide previously unavailable insight into fluid flows. This technique being quantitative is what causes it to differ from dye based flow visualisation, and calculating a field of scalar concentration from an image of a species in a flow field requires an accurate calibration. A full PLIF calibration must be done for every pixel in an image and plots the measured light intensity at each pixel, against it's equivalent dye concentration.

# Summary

$$
E=a(c\ast I)
$$
Equation for fluorescent emittance, where E is the emittance, a is a calibration
constant, c is the dye concentration, and I is the light intensity


Conducting this full pixel by pixel calibration allows the constant (a) and the light intensity (i) to be accounted for, so that the concentration (c) can be quantitatively calculated using the emittance (E).


$$
A=\varepsilon bc
$$
The Beer-Lambert law, where A is absorbance, $\varepsilon$ is absorptivity, b is path length, and c is concentration


In order to know the light intensity (\(i\)) at each pixel, using calibration images, the attenuation through the calibration tank used, must be accounted for, this is done using the Beer-Lambert law.


$$
A=I_{x}-I_{y}
$$
A is equal to Absorbance, $I_{x}$ is light intensity at x, and $I_{y}$ is light intensity at y.



$$
I_{x}-I_{y} = \varepsilon bc
$$
A rearrangement of the Beer Lambert law. $I_{x}$ is light intensity at x, $I_{y}$ is light intensity at y, $\varepsilon$ is absorptivity, b is path length between a and b, and c is concentration


Use of the PLIF technique is unfortunately limited currently within the academic community, with particle image velocimetry being a far more widespread and developed measurement technique. It is hoped that this software package being released as an open source tool will help in use and further development of the PLIF technique. This software package was developed in MATLAB, and currently exists as a package of functions to be called by the user's main function. The University of Southampton Research Software Group is assisting to publish these codes, which will be available on GitHub.


The current version of this software package is intended to take a total of 7 images sets as input, with each image set being averaged down to a single image as step 1. The first set of images should be of the test section with the laser on and no dye present. The next three sets of images showing the test section with a dye calibration tank, slightly moved in between each set of images, the concentration of dye within the tank must be known. The last three sets, showing the same but with a tank of a different, also known, concentration.

Methods to calculate the absorptivity $\varepsilon$ of a solution vary, this software package includes a preliminary version of code to iteratively calculate this from the calibration images. This process mostly uses the existing code and is designed to be optional.




# Citations

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

If you want to cite a software repository URL (e.g. something on GitHub without a preferred
citation) then you can do it with the example BibTeX entry below for @fidgit.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Package Functions

Below is a list of all the function to be included in the package:


\bf PLIF Calibration functions - calib\_calculate\_coefficients
\begin{enumerate}

    \item Average - calib\_average\_frames : A function to average the sets of images used for each calibration tank position.
    
    Input: 7 sets of images
    
    Output: 7 Images
    
    \item Merge - calib\_merge\_frames : A function to merge the 3 tank positions for each dye concentration. The background image does not need merging.
    
    Input: 2 sets of 3 images
    
    Output: 2 Images
    
    \item Trace Rays - calib\_trace\_rays : A function requiring user input to calculate the laser origin based on visible laser lines in the calibration images. In this step sections of the image can also be selected to be deleted and interpolated. 
    
    Input: Laser streak locations.
    
    Output: Laser Source coordinates.
    
    \item Correct Attenuation - calib\_correct\_attenuation : Application of attenuation correction using molar apsorptivity(Epsilon), laser source location, and out of frame tank height.
    
    Input: Molar apsorptivity, out of frame tank height, 2 images.
    
    Output: 2 Images.


    \item Background Intensity Gradient - calculate\_background\_intensity\_gradient : Uses GetBackgroundIntensity on every experiment image to plot the increase in background concentration between start and end of experiment.
    
    Input: All experimental Images.
    
    Output: Gradient of increase in background intensity .

    \item Assess Calibration - calib\_attenuation\_summary\_figures : Prints output figures to check the final inputs to the calibration matrix
    
    Input: Background calibration image and two pre-processed calibration images.
    
    Output: Graphs to check validity of previous calirbation steps.
    
    \item Output Calibration - calib\_make\_final\_frame : Creates calibration curve for each pixel in image and exports as matrix.
    
    Input: Background calibration image and two pre-processed calibration images.
    
    Output: Final calibration matrix.
    
\end{enumerate}

\bf PLIF Processing Function - apply\_calibration\_coefficients
\begin{enumerate}
    \item apply\_calibration\_coefficients: Applies calibration matrix to experimental images.
    
    Input: Experimental images, Calibration matrix.
    
    Output: Processed PLIF images.
    
\end{enumerate}

\bf Epsilon Optimisation Function
\begin{enumerate}
    \item Epsilon Iteration - epsilon\_correct\_attenuation : Uses bisection method to optimise absorptivity value for calibration images.
    
    Input: Laser source coordinates, averaged and merged calibration images.
    
    Output: Optimal Epsilon value for this specific set of images.
    
\end{enumerate}


\bf File Accessing Sub-functions
\begin{enumerate}

     \item get\_scale\_origin: Uses an image of the calibration plate to apply a user defined origin to all images.
    
    Input: Calibration Image, User input.
    
    Output: Image Origin in x and y.

    \item get\_plif\_image: Reads image file, converts from select formats to numerical arrays.

    Input: Path to image.

    Output: Image as numerical array.

    \item get\_laser\_origin: Uses user defined ray tracing to calculate origin of the laser sheet.

    Input: Calibration Images, User input.

    Output: Laser Origin in x and y.

    \item get\_dye\_conc\_filenames: Creates list of file names for calibration concentrations.

    Input: Concentrations of dye in calibration tanks.

    Output: List of calibration image file names.

    \item get\_default\_unset\_parameters: Uses default values from experiments carried out at Southampton as unset values.

    Input: n/a

    Output: Unset parameters.

    \item get\_background\_intensity: Uses a selction of the freestream of the flow with no scalar to estimate the intensity of the background, relative to the original before the experiment began.
    
    Input: Experiment Image, Freestream location.
    
    Output: Relative background intensity.

\end{enumerate}

# Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project.

# References
