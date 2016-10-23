# NamedColors

[![Build Status](https://travis-ci.org/oxinabox/NamedColors.jl.svg?branch=master)](https://travis-ci.org/oxinabox/NamedColors.jl)

[![Coverage Status](https://coveralls.io/repos/oxinabox/NamedColors.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/oxinabox/NamedColors.jl?branch=master)

[![codecov.io](http://codecov.io/github/oxinabox/NamedColors.jl/coverage.svg?branch=master)](http://codecov.io/github/oxinabox/NamedColors.jl?branch=master)

[Colors.jl](https://github.com/JuliaGraphics/Colors.jl#color-parsing) supports about 250 colours as named colorants.
NamedColors.jl supports about 2,500.
Honestly, the named colours in Colors.jl, and/or its capacity to generate good palletes, are far more useful.
But don't you want the quiet smugness the comes from knowing that you presentaton is colored with XKCD's *booger*;
or to really razzele dazzle them with Crayola's *Razzle Dazzle Rose*.
Perhaps you enjoy taking standardization to the next level, with the well define colours of the NBS, ranging from *oliveblack* to  *vividgreenishblue*.

[![A plot showing a random sample of colors from each set](proto/demo.png)


# Sources

 - [X11](https://en.wikipedia.org/wiki/X11_color_names) Standard Colors from the X-Windows system
 - [CSS3](https://www.w3.org/TR/css3-color/) Basic 16 Colors
 - [XKCD](https://blog.xkcd.com/2010/05/03/color-survey-results/) -- The 949 as defined by several hundred thousand participants in the xkcd color name survey.
 - [Resene](http://people.csail.mit.edu/jaffer/Color/resenecolours.txt)  1383 colours from [Resene](http://www.resene.co.nz)
 - [NBS](http://people.csail.mit.edu/jaffer/Color/Dictionaries#nbs-anthus) National Bureau of Statistics. 275 colors
 - [Crayola Crayons](https://en.wikipedia.org/wiki/List_of_Crayola_crayon_colors)  not the full set, but 197 colors
 
 
# Demo
The below code, generates the above chart of random colours.

```julia
using NamedColors
using Colors
using Plots
gr()

const xkcd = load_xkcd();

function compliment{T<:Colorant}(col::T)
    hcol = convert(HSV, col)
    ret=HSV((hcol.h+180)%360, hcol.s, hcol.v)
    convert(T, ret)
end

function rand_subdict(dict::Associative, len::Integer)
    keep_keys = rand(collect(keys(dict)), len)
    Dict(zip(keep_keys, getindex.([dict], keep_keys))) 
end


sample_size=10
plot(background_color=xkcd["blood"], leg=false)
xlims!(0,6+1)
ylims!(-1,sample_size+3)
for (ii,(source_name, sample)) in enumerate([
        ("Crayola", rand_subdict(load_crayola(), sample_size)),
        ("CSS3", rand_subdict(load_css3(), sample_size)),
        ("X11", rand_subdict(load_x11(), sample_size)),
        ("NBS", rand_subdict(load_nbs(), sample_size)),
        ("Resene", rand_subdict(load_resene(), sample_size)),
        ("XKCD", rand_subdict(xkcd, sample_size))])
    
    color_names = collect(keys(sample))
    colors = collect(values(sample))
    com_colors = compliment.(colors)
    
    scatter!(ii*ones(sample_size),1:sample_size,
        color=colors,
        markersize=30,
        series_annotations=text.(color_names, com_colors),     
        annotations=(ii, sample_size+2,text(source_name*":",xkcd["vomit"]))
    )
end
title!("NamedColors Sample")

```




 
 
# Futher Reading
Naming colors is actually something experts exist in.
This package is one for pragmatic use, color names are more complex than many-one lookup tables can provide.

 - http://people.csail.mit.edu/jaffer/Color/Dictionaries
