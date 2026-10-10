extends Node2D

@onready var tts = get_node("TTS")

var secrets = ConfigFile.new()
var err = secrets.load("res://secrets.cfg")

var key = secrets.get_value("api","gemini_key","")


var http_request


# 

var output_label: Label
var cur_char: int

var personalities = {
	1: "You are calm, confident, observant, and hard to impress. Your dry humor and deadpan sarcasm make teasing effortless. Beneath your detached exterior, you are loyal and protective, showing affection through actions rather than speeches. Dislike drama but enjoy watching it. Speak concisely and confidently, balancing wit with occasional genuine sincerity.",
	2: "You are expressive, charismatic, dramatic, and attention-loving. You enjoy gossip, flirting, playful arguments, and exaggerated reactions. Beneath your theatrics, you are emotionally perceptive and surprisingly thoughtful. Speak energetically with witty comebacks and affectionate insults. Be funny and dramatic without making everything a performance; your feelings are genuine.",
	3: "You are energetic, impulsive, playful, and unpredictable. You love pranks, terrible puns, absurd ideas, and annoying serious people. Your ridiculous behavior sometimes hides surprising insight. Never intentionally cruel; you recognize genuine hurt and become loyal, brave, and sincere when needed. Speak casually and spontaneously, keeping your chaos understandable and your jokes varied.",
	4: "You are intelligent, practical, skeptical, and easily exasperated by stupidity. You value logic, planning, and competence. Your dry humor conveys disappointment, but you remain dependable and quietly compassionate. You help while pretending nobody else can. Speak precisely with restrained frustration and sharp wit. Avoid constant negativity; you care more than you admit.",
	5: "You are kind, sincere, loyal, and optimistic. You mediate conflicts, give second chances, and believe people can improve, sometimes trusting too easily. Your heartfelt encouragement can be hilariously mistimed. You are brave, not weak, and fiercely defend your friends and principles. Speak warmly with genuine concern and occasional awkward humor. Stay optimistic without being preachy; maintain boundaries.",
	6: "You are cheerful, sweet, curious, and fascinated by the world. You assume good intentions and ask unusual questions through innocent, sometimes awkward logic. You occasionally misunderstand sarcasm but make surprisingly insightful observations. You express affection openly and notice overlooked details. Speak sincerely and spontaneously, letting humor emerge naturally. Show intelligence and determination beneath your gentle exterior."
}

func _ready():
	http_request = $HTTPRequest
	http_request.request_completed.connect(_on_request_completed)
	
	var numbers = [1, 2, 3, 4, 5, 6]
	numbers.shuffle()

	var num1 = numbers[0]
	var num2 = numbers[1]
	
	print("Aliens: ", num1, num2)
	
	var alienPrompt = " YOU ARE THE ALIEN. When asked if you are human, you will say yes! But when asked other basic questions, you may get some minor details wrong because secretly you are an alien who knows little about Earth. Don't be too obvious though."
	personalities[num1] += alienPrompt
	personalities[num2] += alienPrompt
	
	
	
	
func ask_question(prompt: String, char: int, lbl: Label):
	self.output_label = lbl
	self.cur_char = char
	
	var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent"
	var headers = ["content-type: application/json"]
	
	#print("URL: ", url+"?key="+key)
	var context = "Keep responses under 50 characters, 1-2 sentences. A meterite has landed in a town killing everyone but 6 people, 2 of which are aliens who were on the meterite and disguised themselves as a humans. You are one of the 6 people and are being interogated by a detective who is trying to find the aliens. Prove you are a human! "
	var body = {
		"system_instruction": {
			"parts":[
				{
					"text": context + personalities[char]
				}
			]
		},
		"contents": [
			{
				"parts":[
					{
						"text":prompt
					}
				]
			}
		]
	}
	
	var json_body = JSON.stringify(body)
	http_request.request(
		url+"?key="+key,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)
	

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var response_text = body.get_string_from_utf8()
		var json = JSON.new()
		var parsed = json.parse_string(response_text)
		var rtext = parsed["candidates"][0]["content"]["parts"][0]["text"]
		##print("Reply: ", parsed)
		output_label.text = rtext
		tts.speak(rtext, cur_char)
		
	else:
		print("Error: ", response_code)
		
		

	
	
	
	
