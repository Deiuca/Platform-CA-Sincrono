extends Node2D

#Tipi di cella in questo progetto
enum tipi {ARIA, MURO, PLATFORM}

#Textures nel progetto
#N.B. PRE-COND: tutte le texture devono avere le stesse dimensioni!!!
var aria = preload("res://Texture/trasparente.png")
var muro = preload("res://Texture/nero.png")
var piattaorma = preload("res://Texture/piattaforma.png")
