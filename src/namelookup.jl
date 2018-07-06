
"""
Returns list of similarly named colors, from the color_list
"""
function similarly_named_colors(
		name::AbstractString,
		color_list::AbstractDict{S} = ALL_COLORS) where {S<:AbstractString}
    
	levsort(name, collect(keys(color_list)))
end

struct UnknownColorError{S<:AbstractString} <:Exception
    name::S
    msg::String
end

function UnknownColorError(
		name::AbstractString,
		color_list::AbstractDict{S}) where {S<:AbstractString}
    
	similars = similarly_named_colors(name, color_list)
    msg=if length(similars)==0
        unescape_string("\"$name\" is not a known color name.")
    else
        suggestions = join(repr.(similars), ", ", " or ")
        unescape_string("\"$name\" is not a known color name. Perhaps you meant: $suggestions")
    end
    UnknownColorError(name, msg)
end

Base.showerror(io::IO, ex::UnknownColorError) = print(io, "UnknownColorError: $(ex.msg)")



"""
Returns a color with the given name.
If not found,a list of suggestions is provided.
"""
function named_color(name::AbstractString, color_list::AbstractDict{S} = ALL_COLORS) where {S<:AbstractString}
    
    if haskey(color_list, name)
        color_list[name]
    else
        throw(UnknownColorError(name, color_list))
    end
end



"""
Attempts to find a color to match any name you give it.
First by using the methods from Color.jl's @colorant_str macro,
to handle things like `colorant"#cd32cd"`
Then if that fails, does a lookup in the big list of named colors.
If that fails, then it provides suggestions for what color name you may have meant.
As an user, you basically should just use this, without worrying if a color is defined.
There are almost 3500 defined colors, and if you miss one,
then the suggestions will help you out.
(this is easier than trying to workout the name yourself)
"""
macro colorant_str(name::AbstractString)
    local col
    try
        col = parse(Colorant, name)
    catch ex
        col = named_color(name)
        :($col)
    end
    :($col)
end


