#!/usr/bin/env python3
import json
import re
import requests
from pathlib import Path

# --- Load colors from theme.css ---
theme_path = Path.home() / ".config/waybar/theme.css"
THEME = {}

with theme_path.open() as f:
    for line in f:
        if match := re.match(r"@define-color\s+(\S+)\s+(#[0-9A-Fa-f]{6});", line.strip()):
            key, value = match.groups()
            THEME[key] = value

# --- Icon definitions by weather type ---
THEME_ICONS = {
    'clear':  {'icon': '', },
    'cloud':  {'icon': '', },
    'fog':    {'icon': '', },
    'rain':   {'icon': '', },
    'storm':  {'icon': '', },
    'snow':   {'icon': '', },
}

def styled_icon(category, size=9):
    info = THEME_ICONS.get(category, {'icon': '❓'})
    return f'<span size="{1000*size}" rise="2000">{info["icon"]}</span>'

# --- Map weather codes to categories ---
WEATHER_CATEGORIES = {
    '113': 'clear',
    '116': 'cloud', '119': 'cloud', '122': 'cloud',
    '143': 'fog', '248': 'fog', '260': 'fog',
    '176': 'rain', '179': 'rain', '182': 'rain', '185': 'rain',
    '263': 'rain', '266': 'rain', '281': 'rain', '284': 'rain',
    '293': 'rain', '296': 'rain', '299': 'rain', '302': 'rain',
    '305': 'rain', '308': 'rain', '311': 'rain', '314': 'rain',
    '317': 'rain', '350': 'rain', '353': 'rain', '356': 'rain',
    '359': 'rain', '362': 'rain', '365': 'rain', '374': 'rain',
    '377': 'rain',
    '200': 'storm', '386': 'storm', '389': 'storm', '392': 'storm',
    '227': 'snow', '230': 'snow', '320': 'snow', '323': 'snow',
    '326': 'snow', '329': 'snow', '332': 'snow', '335': 'snow',
    '338': 'snow', '368': 'snow', '371': 'snow', '395': 'snow',
}

# --- Fetch weather data ---
weather = requests.get("https://wttr.in/?format=j1&u").json()
current = weather['current_condition'][0]
area = weather['nearest_area'][0]['areaName'][0]['value']

code = current['weatherCode']
category = WEATHER_CATEGORIES.get(code, 'clear')
icon = styled_icon(category)

desc = current['weatherDesc'][0]['value']
temp = current['temp_C']
feels = current['FeelsLikeC']
wind = current['windspeedKmph']
humidity = current['humidity']

# --- Output JSON for Waybar ---
print(json.dumps({
    "text": f"{icon} {feels}°C",
    "tooltip": (
        f"<b>{area}</b>\n"
        f"{desc} ({temp}°C)\n"
        f"Feels like: {feels}°C\n"
        f"Wind: {wind} Km/h\n"
        f"Humidity: {humidity}%"
    )
}))
