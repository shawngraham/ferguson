ferguson
========

text-analysis files on ferguson grand jury documents

the documents were compiled by [@MitchFraas](http://twitter.com/MitchFraas)

download the source [docs](https://s3.amazonaws.com/fraasdev/FergusonTextGuide.txt)

Mitch also loaded them into [Voyant Tools](http://voyant-tools.org/?corpus=1416958122329.9345&stopList=1416958515132tx)

## caveat utilitor
I haven't interpreted the results yet, nor tried to visualize; am just providing my R script and my initial output files for DH / Data journalist types / others to explore for themselves. The R script does have a piece in it for making word clouds for the various topics, where the size of the word corresponds roughly to the importance of that word in the topic. For more on MALLET and visualizing the results, see the Journal of Digital Humanities, the work of Ted Underwood, Matt Jockers, Andrew Goldstone, etc.

As you look at the topic labels file, you'll see 'october' and 'november' and 'september' and similar (eg roman numerals, words that are appearing in the header/footer of every page etc) that should actually be added to the stoplist file. Then the analysis should be re-run. The stoplist being used is the default Mallet stoplist.

Further analysis might wish to see which documents or which topics correlate with one another (easiest way to do this is to run Excel's correlate function). Or one could look at the correlations of words within the documents. Is Brown always described the same way by witnesses? Do certain topics/discourses associate with Brown more than Wilson (and vice versa)? One could also do sentiment analysis, to see how Brown/Wilson are portrayed by the witnesses, the prosecutor, etc. 
