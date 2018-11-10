# Pupil preprocessing in Matlab

Preprocess EyeLink pupillometry data using the FieldTrip toolbox
Open the pupilTutorial.ipynb for the full Jupyter notebook (see https://anneurai.net/2015/11/12/matlab-based-ipython-notebooks/)

Several of the functions you'll need, for edf2asc conversion and reading in asc files, can be found in my Tools repo https://github.com/anne-urai/Tools/tree/master/eye. Make sure to download all of them, and to ensure the edf2asc is executable by nagivating to the path with the file in Terminal, and typing `chmod +x edf2asc`.

The first section of the code is specific to EyeLink (edf) files. See here https://github.com/anne-urai/pupil-memory/blob/master/code/processPupilData.m for a similar approach, but using files from SMI eyetracker (which have to first be converted using BeGaze).

These methods are used in
*Urai, A.E., Braun, A. & Donner, T.H. Pupil-linked arousal is driven by decision uncertainty and alters serial choice bias. Nature Communications 8,14637 (2017).  DOI: 10.1038/ncomms14637*
If you use this code, please cite the paper.

Don't hesitate to get in touch (anne.urai [at] gmail [dot] com) if you have any questions.
