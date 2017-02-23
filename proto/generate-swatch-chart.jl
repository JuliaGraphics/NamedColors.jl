#!/usr/bin/env julia

using Luxor, Colors, NamedColors

"""
compare two colors, looking just at their LUV luminance values
"""
function compare_colors(color_a, color_b)
    color_x = convert(Luv, RGB(color_a...))
    color_y = convert(Luv, RGB(color_b...))
    getfield(color_x, :l) > getfield(color_y, :l)
end

"""
draw a swatch
"""
function draw_swatch(colorname, colorvalues, pt, swatchwidth, swatchheight, column)
    gsave()
    translate(pt)
    sethue(colorvalues...)
    box(O, swatchwidth, swatchheight, :fill)
    sethue("black")
    # alternate label's y coordinates because some are so bleeding wide
    column % 2 == 0 ? text(colorname, O.x, -swatchheight/2 - 1, halign=:center) : text(colorname, O.x, -swatchheight/2 - 3, halign=:center)
    grestore()
end

"""
draw a slightly gray background behind the very light colors but stop doing it
by the time you get to the not so light ones
"""
function drawbackground(imagewidth, imageheight)
    blend_white_black = blend(Point(0, 0), Point(0, imageheight), "grey95", "white")
    setblend(blend_white_black)
    box(imagewidth/2, imageheight/2, imagewidth, imageheight, :fill)
end

function main(imagewidth, imageheight)
    # first create reverse synonym dictionary, color values as keys, color names as values
    synonyms = Dict{Tuple, Array}()
    for (k, v) in ALL_COLORS
        col_name  = k
        col_value = (red(v), green(v), blue(v))
        # get rid of this UFixed stuff first
        col_value_f = map(x -> convert(Float64, x), col_value)
        # float64 3tuple as dictionary keys, yay, cool
        if haskey(synonyms, col_value_f)
            push!(synonyms[col_value_f], col_name)
        else
            synonyms[col_value_f] = [col_name]
        end
    end

    # calculate sizes of swatches
    aspect = imagewidth/imageheight
    if aspect > 1
        n_rows = ceil(sqrt(length(synonyms)/aspect))
    else
        n_rows = ceil(sqrt(length(synonyms) * aspect))
    end
    n_cols = ceil(length(synonyms)/n_rows)

    margin = 30
    row_space = 20
    col_space = 5
    swatchwidth  = ((imagewidth  - 2margin - (col_space * n_cols )) / n_cols)
    swatchheight = ((imageheight - 2margin - (row_space * n_rows )) / n_rows)

    Drawing(imagewidth, imageheight, "/tmp/namedcolors.pdf")
    drawbackground(imagewidth, imageheight)
    fontsize(3)
    column = 1
    x, y = margin, 3margin

    for color_values in sort(collect(keys(synonyms)), lt = (x, y) -> compare_colors(x, y))
        color_synonyms = sort(synonyms[color_values])

        # draw the swatch
        draw_swatch(color_synonyms[1], color_values, Point(x, y), swatchwidth, swatchheight, column)

        # synonyms
        oldy = y # save the current y position during excursion
        for synonym in color_synonyms[2:end]
            # draw the other names for this color underneath
            fontsize(2)
            sethue("black")
            text(":$synonym", x - swatchwidth/2, y + swatchheight/2 + 2)
            fontsize(3)
            y += 2
        end
        y = oldy

        if x > (imagewidth - swatchwidth - margin)
            x = margin # next row
            column = 1
            y += swatchheight + row_space
        else
            x += swatchwidth + col_space
        end
        column += 1
    end

    # title
    fontsize(24)
    fontface("Eurostile-Bold")
    sethue(colorant"poop brown") # seriously useful color
    text("NamedColors.jl, sorted by/with LUV", imagewidth/2, 1.5margin, halign=:center)
    #footer
    fontsize(10)
    text("drawn $(Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")), $(length(ALL_COLORS)) named colors", imagewidth/2, imageheight-margin, halign=:center)
    finish()
    preview()
end

main(paper_sizes["A1"]...)
