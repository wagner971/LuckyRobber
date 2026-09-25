from pathlib import Path
import re, colorsys
root=Path('.')
files=['game_ui.gd','hud_style.gd','result_presentation.gd','move_input.gd','loot_guidance.gd','menu_character_preview.gd','home_showcase_set.gd','garage_decor.gd','screen_motion.gd']
def recolor(rgb):
 h,s,v=colorsys.rgb_to_hsv(*rgb)
 if .48 <= h <= .70 and s > .12:
  return colorsys.hsv_to_rgb(.765,s,v)
 return rgb
for name in files:
 p=root/'scripts'/name
 s=p.read_text(encoding='utf-8-sig')
 def hexcolor(m):
  value=m[1];rgb=tuple(int(value[i:i+2],16)/255 for i in (0,2,4));new=recolor(rgb)
  return 'Color("'+''.join(f'{round(c*255):02x}' for c in new)+value[6:]+'")'
 s=re.sub(r'Color\("([0-9a-fA-F]{6}(?:[0-9a-fA-F]{2})?)"\)',hexcolor,s)
 def numeric(m):
  new=recolor(tuple(float(m[i]) for i in (1,2,3)))
  return 'Color('+', '.join(f'{c:.4f}' for c in new)+(m[4] or '')+')'
 s=re.sub(r'Color\((0?\.\d+|1\.0),\s*(0?\.\d+|1\.0),\s*(0?\.\d+|1\.0)(,\s*[.\d]+)?\)',numeric,s)
 p.write_text(s,encoding='utf-8')
p=root/'scripts/game_ui.gd'
s=p.read_text(encoding='utf-8')
a=s.index('\tvar logo = Control.new()',s.index('func home('));b=s.index('\tvar preview = add_preview',a)
s=s[:a]+'''\tvar logo = TextureRect.new()
\tlogo.name = "HomeLogo"
\tlogo.texture = preload("res://assets/ui/menu_violet/title.png")
\tlogo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
\tlogo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
\tlogo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
\tlogo.custom_minimum_size.y = 190
\tlogo.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tbody.add_child(logo)
'''+s[b:]
s=s.replace('res://assets/ui/home/daily-wheel.png','res://assets/ui/menu_violet/wheel.png')
s=s.replace('var tab = button(links, entry[0],','var tab = button(links, "",')
s=s.replace('\t\ttab.clip_text = true','\t\ttab.tooltip_text = entry[0]\n\t\ttab.accessibility_name = entry[0]\n\t\ttab.clip_text = true')
s=s.replace('style.content_margin_top = 49 if height >= 90 else (31 if height >= 65 else 24)','style.content_margin_top = 3')
s=s.replace('icon.texture = load("res://assets/ui/jobs/nav/" + entry[2] + ".svg")','icon.texture = load("res://assets/ui/menu_violet/" + {"house":"home", "target":"jobs", "wrench":"upgrades", "garage":"garage"}[entry[2]] + ".png")')
a=s.index('\t\ticon.custom_minimum_size = Vector2(41');b=s.index('\t\ticon.mouse_filter',a)
s=s[:a]+'''\t\ticon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
\t\ticon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
\t\ticon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
\t\ticon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
\t\ticon.offset_left = 12
\t\ticon.offset_right = -12
\t\ticon.offset_top = 5
\t\ticon.offset_bottom = -5
'''+s[b:]
s=s.replace('var shortcut = blue_button(parent, label, callback, 111)','var shortcut = blue_button(parent, "", callback, 111)\n\tshortcut.tooltip_text = label\n\tshortcut.accessibility_name = label')
s=s.replace('style.content_margin_top = 62','style.content_margin_top = 3')
s=s.replace('icon.texture = load("res://assets/ui/home/" + icon_name + ".svg")','icon.texture = load("res://assets/ui/menu_violet/" + {"dumbbell":"upgrades", "garage":"garage", "cap":"cosmetics"}[icon_name] + ".png")')
a=s.index('\ticon.custom_minimum_size = Vector2(54',s.index('func home_shortcut'));b=s.index('\ticon.mouse_filter',a)
s=s[:a]+'''\ticon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
\ticon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
\ticon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
\ticon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
\ticon.offset_left = 15
\ticon.offset_right = -15
\ticon.offset_top = 3
\ticon.offset_bottom = -3
'''+s[b:]
s=s.replace('res://assets/ui/upgrades/%s.svg','res://assets/ui/menu_violet/powerups/%s.png')
p.write_text(s,encoding='utf-8')
from PIL import Image
for name in ['title','upgrades','garage']:
 im=Image.open(root/'assets/ui/menu_violet'/f'{name}.png')
 print(name,im.mode,im.size,im.getpixel((0,0)),im.getbbox())
