#!/usr/bin/env node
const _ = require("lodash");
const colorPalette = require("tailwindcss/colors");

// The relevant color scales are `object`s, but Tailwind supports the previous names
//   for some colors so they need to be removed, as well. (String colors are
//   black/white and some CSS-related fallbacks.
const deprecatedColors = ["lightBlue", "warmGray", "trueGray", "coolGray",  "blueGray"];
const desiredColors = _.pickBy(
  colorPalette,
  (value, key) => _.isPlainObject(value) && !deprecatedColors.includes(key),
);

// Since the JS is structed as a deep `object` (Dict), this destructures the depth
//   into a dotted scheme (e.g. `Dict(:blue => Dict(500 => "#RRGGBB"))` ->
//   `Dict("blue.500" => "#RRGGBB")`)
const colors = _.reduce(desiredColors, (colorMap, colorScale2Hex, colorName) => {
  _.map(colorScale2Hex, (colorHex, colorScale) => {
    colorMap[`${colorName}.${colorScale}`] = colorHex;
  })
  return colorMap;
}, {});

// This is fluff just to make the output file a little more readable
const longestColorNameScale = _.size(_.maxBy(_.keys(colors), _.size));

// Printing each [color, hex] pair to stdout so the Julia script can write to
//   `data/tailwind.txt`.
for (const [colorName, colorHex] of Object.entries(colors)) {
  console.log(`${_.padEnd(colorName, longestColorNameScale, " ")}    ${colorHex}`)
}
