---
title: 'Gala: A Python package for galactic dynamics'
tags:
  - matlab
  - astronomy
  - dynamics
  - galactic dynamics
  - milky way
authors:
  - name: Adrian M. Price-Whelan
    orcid: 0000-0000-0000-0000
    equal-contrib: true
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
  - name: Author Without ORCID
    equal-contrib: true # (This is how you can denote equal contributions between multiple authors)
    affiliation: 2
  - name: Author with no affiliation
    corresponding: true # (This is how to denote the corresponding author)
    affiliation: 3
affiliations:
 - name: Lyman Spitzer, Jr. Fellow, Princeton University, USA
   index: 1
 - name: Institution Name, Country
   index: 2
 - name: Independent Researcher, Country
   index: 3
date: 13 August 2017
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
aas-journal: Astrophysical Journal <- The name of the AAS journal.
---

# Summary

Optical measurement methods in fluid dynamics are an extensively used and understood field, there are several intrinsic advantages to this category of techniques. First of which is that they can be used to observe an entire plane of a flow at once, as opposed to techniques like hot wire annemometry, which take point measurements. Optical techniques are also non intrusive, and therefore exert little influence on the flow itself.

Planar Laser Induced Fluorescence (PLIF) is a technique used to quantitatively measure the concentration of a fluorescent species in a flow. This technique is a useful tool to calculate dispersive fluxes when combined with particle image velocimetry, and can provide previously unavailable insight into fluid flows. This technique being quantitative is what causes it to differ from dye based flow visualisation, and calculating a field of scalar concentration from an image of a species in a flow field requires an accurate calibration. A full PLIF calibration must be done for every pixel in an image and plots the measured light intensity at each pixel, against it's equivalent dye concentration.


\begin{eqfloat}
\begin{equation}
E=a(c\ast I)
\end{equation}
\caption{Equation for fluorescent emittance, where E is the emittance, a is a calibration
constant, c is the dye concentration, and I is the light intensity}
\label{epsilon_emittance_eq}
\end{eqfloat}

Conducting this full pixel by pixel calibration allows the constant (a) and the light intensity (i) to be accounted for, so that the concentration (c) can be quantitatively calculated using the emittance (E).

\begin{eqfloat}
\begin{equation}
A=\varepsilon bc
\end{equation}
\caption{The Beer-Lambert law, where A is absorbance, \(\varepsilon\) is absorptivity, b is path length, and c is concentration}
\label{BL_law_equation}
\end{eqfloat}

In order to know the light intensity (\(i\)) at each pixel, using calibration images, the attenuation through the calibration tank used, must be accounted for, this is done using the Beer-Lambert law.

\begin{eqfloat}
\begin{equation}
A=I_{x}-I_{y}
\end{equation}
\caption{A is equal to Absorbance, \(I_{x}\) is light intensity at x, and \(I_{y}\) is light intensity at y.}
\label{BL_law_rearrangement}
\end{eqfloat}

\begin{eqfloat}
\begin{equation}
I_{x}-I_{y} = \varepsilon bc
\end{equation}
\caption{A rearrangement of the Beer Lambert law. \(I_{x}\) is light intensity at x, \(I_{y}\) is light intensity at y, \(\varepsilon\) is absorptivity, b is path length between a and b, and c is concentration}
\label{BL_law_rearranged}
\end{eqfloat}


# Statement of need

`Gala` is an Astropy-affiliated Python package for galactic dynamics. Python
enables wrapping low-level languages (e.g., C) for speed without losing
flexibility or ease-of-use in the user-interface. The API for `Gala` was
designed to provide a class-based and user-friendly interface to fast (C or
Cython-optimized) implementations of common operations such as gravitational
potential and force evaluation, orbit integration, dynamical transformations,
and chaos indicators for nonlinear dynamics. `Gala` also relies heavily on and
interfaces well with the implementations of physical units and astronomical
coordinate systems in the `Astropy` package [@astropy] (`astropy.units` and
`astropy.coordinates`).

`Gala` was designed to be used by both astronomical researchers and by
students in courses on gravitational dynamics or astronomy. It has already been
used in a number of scientific publications [@Pearson:2017] and has also been
used in graduate courses on Galactic dynamics to, e.g., provide interactive
visualizations of textbook material [@Binney:2008]. The combination of speed,
design, and support for Astropy functionality in `Gala` will enable exciting
scientific explorations of forthcoming data releases from the *Gaia* mission
[@gaia] by students and experts alike.

# Mathematics

Single dollars ($) are required for inline mathematics e.g. $f(x) = e^{\pi/x}$

Double dollars make self-standing equations:

$$\Theta(x) = \left\{\begin{array}{l}
0\textrm{ if } x < 0\cr
1\textrm{ else}
\end{array}\right.$$

You can also use plain \LaTeX for equations
\begin{equation}\label{eq:fourier}
\hat f(\omega) = \int_{-\infty}^{\infty} f(x) e^{i\omega x} dx
\end{equation}
and refer to \autoref{eq:fourier} from text.

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

# Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example}](figure.png)
and referenced from text using \autoref{fig:example}.

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](figure.png){ width=20% }

# Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project.

# References