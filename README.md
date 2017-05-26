# Liter-Of-Light
## Overview:
Based on the idea by the Brazilian mechanic Alfredo Moser, a social enterprise under the My Shelter Foundation was launched in the Philippines by Illa Diaz in spring 2011: A transparent plastic bottle (1.5 – 2 liters) is filled with water plus some bleach (to prevent algae growth) and then fitted into a hole in the roof of a typical windowless slum hovel.

During daytime this design performs like a light bulb and delivers light equivalent to 40-60 watt to the interior – just by refraction of sunlight! It simply works, the solar lights are easily constructed at virtually no cost and the aim of the My Shelter Foundation is to illuminate 1 million homes by the end of 2017. 

## Aim:
+ Can we model the light bottle to verify the amount of light reaching the interior of a hovel? 
+ Is it really 40-60 watt, how deep do we have to mount the bottle into the roof and which role does the shape of the bottle play? 
+ Is it even possible to compute an ideal shape for the bottle? 

***

## Roadmap:
### Finished:
+ Create 3D model of a bottle (surface)
+ Model light rays
+ Compute refraction and reflection direction on surface
+ Model outgoing light rays

### In progress:
+ Model light intesity for incoming rays
+ Compute light intensity for outgoing rays
+ Port main routines to C++ for increase of performance
+ Bug fixing
+ Optimize performance

### Future:
+ Verify the claims/aims stated above
+ Using other representations of the surface, e.g. NURBs
    + Model other shapes
    + Generalize computations
    + Optimize shape
+ More bug fixing
+ Further optimizations
