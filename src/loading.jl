function datafile(filename)
	joinpath(dirname(@__FILE__),"..","data", filename)
end

"""
Parses as string of the form #RRGGBB
eg \"#32CD32\" (limegreen) into a color
"""
parse_hexcode(h::AbstractString) = reinterpret(RGB24, parse(UInt32,h[2:end],16))

"Parses three strings that are integers between 0-255, and converts to color"
function parse_decimal256(r::AbstractString, 
                            g::AbstractString,
                            b::AbstractString)
    ret = 0x00_00_00_00
    ret+=parse(UInt8,r)
    ret<<=8
    ret+=parse(UInt8,g)
    ret<<=8
    ret+=parse(UInt8,b)
    reinterpret(RGB24, ret)
end



"""
Load the color list from the [XKCD color survey](https://blog.xkcd.com/2010/05/03/color-survey-results/).
These colors are suitable for use with (modern) monitors
"""
function load_xkcd()
	linefields = (split(line,"\t") for line in eachline(datafile("xkcd.txt")))
	Dict((name => parse_hexcode(code)) for (name,code) in linefields) 
end


"""
load the color list from Resene Paints Ltd
These colors are best used with paint.
"""
function load_resene()
    
    lines = eachline(datafile("resenecolours.txt"))
    for line in lines 
        startswith(line, "\"Colour Name\"") && break
    end
    #get to the good part
    
    data = Dict{String, RGB24}()
    
    for line in lines
        namefield, rr, gg, bb = split(line,"\t")
        name = namefield[1+length("\"Resene ") : end-1] #skip the end \"
        data[name] = parse_decimal256(rr, gg, bb)
    end
    data
end


"""
Loads an x11 style color list.
Lines are of the form
`r g b name which may have spaces`
the `r`, `g` and `b` terms are numbers between 0 and 256 in decimal
Lines starting with `!` are comments and are skipped
"""
function load_x11_style(path)
	lines = eachline(path)
    data = Dict{String, RGB24}()
    for line in lines
        line[1]=='!'  && continue
        fields = split(line)
        length(fields)==-0 && continue 
		r, g, b = fields[1:3]
        name = strip(join(fields[4:end]," "))
        data[name] = parse_decimal256(r,g,b)
    end
    data
end

"""
Loads the NBS-ISCC color dictionary from

    Kenneth L. Kelly and Deanne B. Judd.
    "Color: Universal Language and Dictionary of Names",
    National Bureau of Standards,
    Spec. Publ. 440, Dec. 1976, 189 pages

Featuring the corrections by John Foster 
to the orignal computer entry of David Mundie

This is suitable for surface colors
"""
load_nbs() = load_x11_style(datafile("NBS-ISCC-rgb.txt"))

"""
Loads the ``Standard'' X11 color-lists
These colours are good for monitors.
To be explict, these colours are good for Paul Raveling's HP Monitor
"""
load_x11() = load_x11_style(datafile("x11rgb.txt"))

"""
Load the W3C defined "Basic Colors".
In theory these are as safe as it gets.
These should be good everywhere.
"""
load_css3() = load_x11_style(datafile("css3.txt"))

"""
Load the set of colors from Crayola Crayons.
This is not the complete list, but it is extensive.
"""
load_crayola() = load_x11_style(datafile("crayola.txt"))

