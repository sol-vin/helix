require "raylib-cr"

module Helix
end

alias Vector2 = Raylib::Vector2
alias Vector3 = Raylib::Vector3


require "./helix/wordsalad"
require "./helix/data/**"

require "./helix/macros"
require "./helix/species"

require "./helix/genes/position"
require "./helix/genes/rotation"

require "./helix/genes/rectangle"
require "./helix/genes/iobb"

require "./helix/genes/circle"









