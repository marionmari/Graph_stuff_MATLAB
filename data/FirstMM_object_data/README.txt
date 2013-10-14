
================================================================================
 Copyright (C) 2013
 Marion Neumann [marion dot neumann at uni-bonn dot de]
 Plinio Moreno [plinio at isr dot ist dot utl dot pt]
 Laura Antanas [laura dot antanas at cs dot kuleuven dot be]

 This file is part of FirstMM_object_data.

 FirstMM_object_data by M. Neumann, P. Moreno, L. Antanas is licensed 
 under a Creative Commons Attribution-ShareAlike 3.0 Unported License 
 (http://creativecommons.org/licenses/by-sa/3.0/).

 FirstMM_object_data is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the Creative
 Commons Attribution-ShareAlike 3.0 Unported License for more details.

 You should have received a copy of the Creative Commons 
 Attribution-ShareAlike 3.0 Unported License along with this program;
 if not, see <http://creativecommons.org/licenses/by-sa/3.0/>.
 
 UPDATES:
 updated version 18/Aug/2013 (freeform_pot_long and freeform_pot_short updated) 
================================================================================

=========================
READ and VISUALIZE DATA:
=========================
To read the data in matlab use read_DB_data.m for the objects in DB and read_SEMI_data.m for the objects in SEMI.
In DB each .mat file represents a different object. In SEMI each .mat file represents a different view from various
objects. That is the 'object' can be obtained from the *same* object assuming a different view. There are up to 8
views per object. For visulaization use plot_object.m.

=========================
DATA DESCRIPTION:
=========================
The FirstMM_object_data is generated with the help of the orca simulator (http://orca-robotics.sourceforge.net)
and a detailed description including data statistics can be found in "M. Neumann, P. Moreno, L. Antanas, R.
Garnett, Kristian Kersting. Graph Kernels for Object Category Prediction in Task-Dependent Robot Grasping. In
Proceedings of the Eleventh Workshop on Mining and Learning with Graphs (MLG{--}2013) at KDD 2013, Chicago, US,
Aug. 11 2013".

FirstMM_object_data comprises 2 datasets, DB (41 objects) and SEMI (126 objects).
The data for each object is stored in a separate .mat file and contains: 
    3D coordinates of points (pointCloudObjectFrame)
    3D normals of points (normals)
    part labels of points (regionIndexes)
    graph representation (weighted adjacency matrix) of the point cloud (knn-graph)
    object category (category).
    
 There are 5 different parts (part labels):
     1 'bottom'
     2 'middle'
     3 'top'
     4 'handle'
     5 'usable_area'.
     
 Each object is of one of the following 11 categories:    
    1 'cup'
    2 'glass'
    3 'can'
    4 'knife'
    5 'pot'
    6 'pan'
    7 'bowl'
    8 'kitchen_tool'
    9 'screwdriver'
    10 'hammer'
    11 'bottle'.
Object names and the corresponding categories are provided in objs_cats_DB.txt and objs_cats_SEMI.txt respectively. 

=====
DB
=====
For this dataset data acquisition is fully simulated. That is, we have the complete point cloud of the input
object and a semantic part label for each point. The point cloud is obtained from a previously defined
3D mesh of the object by up-sampling points using midpoint surface subdivision. Object parts are extracted manually
from the point cloud. 
Further, we provide the normals to each point and a kNN-graph per point cloud.
For each object point cloud the weighted k-nn graph is derived by connecting the k nearest points w.r.t. Euclidean
distance in 3D. We use a four-neighbourhood (i.e., k = 4) and assign an edge weight reflecting the tangent plane
orientations of its incident nodes to encode changes in the object surface. The weight of edge (i, j) between two nodes
is given by w(i,j) = |n_i á n_j|, where n_i is the normal of point i. According to the object parts, the nodes have 5
semantic classes encoding object part information: top, middle, bottom, handle and usable area. This dataset contains
41 objects belonging to 11 categories.

=====
SEMI
=====
For this dataset the point clouds are simulated laser range data and the following steps of obtaining the scene
description are executed in the orca simulator. The point cloud of the query object is estimated from several view points.
The 3D data for each view is acquired from a simulated range camera (with the parameters of the Kinect sensor), placed on
the robot platform. For each object we use between 1 and 8 views depending on whether the object is symmetric or not. The
labels are again obtained manually from the realistic point cloud. This dataset contains 126 labeled point clouds of 26
different objects of all categories except 'cooking tool'.

============================
If you have any questions or troubles in reading the data, let me know [marion dot neumann at uni-bonn dot de].
