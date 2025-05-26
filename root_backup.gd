extends Node3D

var URL: String = "https://www.youtube.com/watch?v=O8tP2_wKSjM"

func _ready() -> void:
	$WebView.connect("view_ready", _on_view_ready)
	$WebView.url = URL

func _on_view_ready():
	$WebView.load()
