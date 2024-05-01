extends Node2D

#Tipi di cella in questo progetto
enum tipi {
ARIA, MURO, 
PLATFORM, PLATFORM_OBSTACLE, PLATFORM_OBSTACLE_DOWN,
EDGE_DOWN, 
RAMPA_DOWN
}

#Textures nel progetto
#N.B. PRE-COND: tutte le texture devono avere le stesse dimensioni!!!
var aria = preload("res://Texture/trasparente.png")
var muro = preload("res://Texture/nero.png")
var piattaforma = preload("res://Texture/piattaforma.png")
var piattaforma_ostacolo = preload("res://Texture/piattaforma_ostacolo.png")
var piattaforma_ostacolo_down = preload("res://Texture/piattaforma_ostacolo_down.png")
var edge_down = preload("res://Texture/edge_down.png")
var rampa_down = preload("res://Texture/rampa_down.png")
