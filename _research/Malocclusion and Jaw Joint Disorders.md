---
layout: project
title: Malocclusion and Jaw Joint Disorders
caption: A Look into Auto-segmentation and Quantification of Medical Scans
description: >
  Many tasks in dentistry require the segmentation of medial images. Human-provided segmentation has proven to be slow, prone to errors, inconsistent, and require specialized training. The overarching purpose of this study is to utilize 3D mouth scans with jaw disk MRI images to determine if there is a significant relationship between malocclusion (ie. the misalignment of the upper and lower teeth) and temporomandibular joint disorders. However, as equally important in this study is the utilization of auto-segmentation techniques on both 3D point clouds and MRI images to achieve this analysis. For this, the architecture called TSegNet was utilized as a starting point. Afterwards, post processing includes robust regression to quantify the misalignment of these teeth points. Due to unforeseen circumstances during the research, as well as time constraints, the MRI section of this research is still ongoing as of writing this paper. However, the idea is to utilize a Unet architecture, trained on 512 × 512 .png’s, gray-scaled and normalized. The mask of the articular disk segmented will then be used to determine the location of the articular disk and its relative position against the articular fossa to quantify misalignment. Results from TSegNet indicate that the model does phenomenally on standard teeth and their alignment. However, the model falls short when coming into contact with heavily misaligned datapoints.
date: 2024-08-30
links:
  - title: Github
    url: https://github.com/dscpsyl/ToothGroupNetwork
---

<figure class="file">
  <embed 
    src="../assets/img/research/Malocclusion and Jaw Joint Disorders/Paper.pdf" 
    type="application/pdf" 
    width="100%" 
    style="border: 1px solid #ddd; border-radius: 4px;">
</figure>

<figure class="file">
  <embed 
    src="../assets/img/research/Malocclusion and Jaw Joint Disorders/Powerpoint.pdf" 
    type="application/pdf" 
    width="100%" 
    style="border: 1px solid #ddd; border-radius: 4px;">
</figure>

