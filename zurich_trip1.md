# Meeting 27 Feb summary (Prof. Grewe, Ben, Prof. Steger)

1. Feedback regarding the annotation tool.
The conept is good - this is the way to create the labels. It is good to stay with the idea of labelling individual events. The labelling process proposed is likely not very time consuming, however the human factor of any labelling task being tedious can be better taken into account. 

The main issue is to obtain correct labels for difficult cases (overlaps) correctly. Labelling easy cases is simple and given the large number of events to label, it is possible that the difficult cases wil not be paid enough attention and would be mislabelled. E.g. if there are 30 events for a filter and 28 of them seem obviosuly valid, this may be a big contrast to the the other two which may also be valid, but will be labelled as invalid, thus resulting in a false negative. 

The same way, the 'convenience buttons' I proposed with labelling all events as valid or invalid all at once, may further this issue.

In short, Prof. Steger suggested that after a person has labelled many events already, they may take too strong assumptions about following ones, while labelling difficult cases is particularly gentle. I had asumed this issue would not be present.

An approach suggested by Prof. Steger is to devise a seperation of concerns. One possible way could be an automated solution to seperate easy cases from difficult cases. Such a separation could be done e.g. by calculating the centre of mass of each event, apply a binary threshold and thus create two labelling sets. Difficult cases would fall above the threshold. The assumption here is that once the easy cases are taken aside, they would pose a lower contrast to the difficut ones and one would not loose their precision in the labelling process. 

1. Feedback regarding the frame viewer.



1. Feedback regarding the learning procedure.
The concept of labelling the data with binary images, created with 