extends Node

var secrets = ConfigFile.new()
var err = secrets.load("res://secrets.cfg")

var voicekey = secrets.get_value("api","elevenlabs_key","")
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


var http_request

var voices = {
	1: "DtQLDxHbTiQTpVVanTy1",
	2: "WZlYpi1yf6zJhNWXih74",
	3: "OYTbf65OHHFELVut7v2H",
	4: "QAmlwgbPtjxpk7u98Qs9",
	5: "ogwqBH5bbF03DSbNiRNN",
	6: "ZF6FPAbjXT4488VcRRnw"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	http_request = $HTTPRequest
	http_request.request_completed.connect(_on_request_completed)

func speak(text: String, char: int):
	var url = "https://api.elevenlabs.io/v1/text-to-speech/" + voices[char]
	var headers = [
		"xi-api-key: "+voicekey,
		"Content-Type: application/json"
	]
	
	var body = {
		"text": text,
		"model_id": "eleven_flash_v2_5"
	}
	
	var json_body = JSON.stringify(body)
	
	var error = http_request.request(
		url+"?output_format=mp3_44100_128",
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)
	
	if error != OK:
		print("Failed to send request: ", error)

func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
):
	if response_code == 200:
		var audio = AudioStreamMP3.load_from_buffer(body)
		audio_player.stream = audio
		audio_player.play()
	else:
		print("ElevenLabs error: ", response_code)
		print(body.get_string_from_utf8())
