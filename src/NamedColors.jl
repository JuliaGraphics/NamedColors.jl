module NamedColors
using ColorTypes
using REPL: levsort
import Colors: @colorant_str

export load_xkcd, load_resene, load_nbs, load_x11_style, load_winsor_newton, load_x11, load_css3, load_crayola, ALL_COLORS, @colorant_str, UnknownColorError, named_color

include("loading.jl")

"""
Loads a combined collection of all colors.
Name clashes are resolved byt the load order.
Which is defined, as from largest collection, to smalled collection.
This is the initialised for the globel const ALL_COLORS, used by "@colorant"
"""
function load_all_colors(load_functions = (
    load_resene,
    load_xkcd,
    load_nbs,
	load_winsor_newton,
    load_x11,
    load_crayola,
    load_css3,
    load_paul_tol,
    ))

    merge!(Dict{String, RGB24}(), map(x->x(), load_functions)...)
end

const ALL_COLORS = load_all_colors()


include("namelookup.jl")

end # module
