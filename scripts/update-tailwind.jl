#!/usr/bin/env julia
"""A script to extract and dump the colors from TailwindCSS.

The source data for the color paletee is on GitHub: https://github.com/tailwindlabs/tailwindcss/blob/master/src/public/colors.js

The color palette can be viewed here: https://tailwindcss.com/docs/customizing-colors

Last updated on 05 Jun 2023.
"""
using NodeJS
using JSON

scriptsdir = dirname(@__FILE__)
cd(scriptsdir)

run(`npm install -g tailwindcss`)
run(`npm install -g lodash`)

datafile = joinpath(dirname(@__FILE__), "..", "data", "tailwind.txt")

const deprecatedcolors = ["lightBlue", "warmGray", "trueGray", "coolGray", "blueGray"]

colors = read(`node -e "console.log(JSON.stringify(require('tailwindcss/colors')))"`, String)
colors = JSON.parse(colors)

colors = filter(color -> !in(first(color), deprecatedcolors), colors)
colors = filter(color -> !isa(last(color), String), colors)

colorlevels = Dict{String, String}()
for (color, levels) in colors
    for (level, hex) in levels
        colorlevels["$(color).$(level)"] = hex
    end
end
# Sorting doesn't technically order correctly because `amber.50` < `amber.100`, but it
#   shouldn't _really_ matter unless the `data/tailwind.txt` file __needs__ to match the
#   sorting of TailwindCSS's color page (unlikely).
colorlevels = sort(colorlevels)

max_charlen = maximum(length, keys(colorlevels))

#! The output colors are not sorted as they are on TailwindCSS's website. The incoming
#!   JSON is sorted accordingly, but it's unclear why `JSON.parse` reorders the keys.
tailwind = open(datafile, "w")

write(tailwind, """
; "tailwind.txt" color dictionary
; The colors from Tailwind CSS, https://tailwindcss.com/docs/customizing-colors.
;
; Transcribed to NamedColors.jl by John Muchovej (jmuchovej).
;
""")

for (colorlevel, hex) in colorlevels
    write(tailwind, "$(rpad(colorlevel, max_charlen, " "))    $(hex)\n")
end
close(tailwind)