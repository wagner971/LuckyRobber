from pathlib import Path
import re, colorsys
for name in ['game_ui.gd','hud_style.gd','result_presentation.gd','move_input.gd','loot_guidance.gd','menu_character_preview.gd','home_showcase_set.gd','garage_decor.gd','screen_motion.gd']:
 p=Path('scripts')/name;s=p.read_text(encoding='utf-8-sig')
 def convert(m):
  val=m[1];rgb=tuple(int(val[i:i+2],16)/255 for i in (0,2,4));h,sat,v=colorsys.rgb_to_hsv(*rgb)
  if .48<=h<=.70 and sat>.12: rgb=colorsys.hsv_to_rgb(.765,sat,v)
  return 'Color("'+''.join(f'{round(c*255):02x}' for c in rgb)+val[6:]+'",'+m[2]+')'
 s=re.sub(r'Color\("([0-9a-fA-F]{6}(?:[0-9a-fA-F]{2})?)",([^\)]+)\)',convert,s)
 p.write_text(s,encoding='utf-8')
