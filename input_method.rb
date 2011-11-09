# Creates input method file for Cantonese Yale romanization.  Must be opened in an editor like
# TextMate and saved as UTF-16 to work properly, as this outputs in UTF-8.

initials = %w|b p m f d t n l g k ng h gw kw w j ch s y|
finals = %w|a aai aau aam aan aang aap aat aak ai au am an ang ap at ak e ei eng ek i iu im in ing ip it ik o oi ou on ong ot ok u ui un ung ut uk eu eui eun eung eut euk yu yun yut|
standalones = %w|m ng|

syllables = []

standalones.each do |standalone|
  syllables << standalone
  syllables << standalone[0].upcase + standalone[1..-1]
end

initials.each do |initial|
  finals.each do |final|
    syllables << initial + final
    syllables << initial[0].upcase + initial[1..-1] + final
  end
end

high_char = "\u0304"
rising_char = "\u0301"
falling_char = "\u0300"

input_mappings = []
syllables.each do |syllable|
  (1..6).each do |tone|
    syl = syllable.clone
    
    case syllable.downcase
    when 'm','ng'
      case tone
      when 4,5,6
        syl << 'h'
      end
    else
      last_vowel_index = syl.rindex(/[aeiou]/)

      raise "last vowel not found in #{syl}" unless last_vowel_index

      # add the 'h' character based on tone
      case tone
      when 4,5,6
        syl[last_vowel_index+1,0] = "h"
      end
    end
    
    case syllable.downcase
    when 'm','ng'
      case tone
      when 1
        syl << high_char
      when 4
        syl << falling_char
      when 2,5
        syl << rising_char
      end
    else
      first_vowel_index = syl =~ /[aeiou]/

      raise "first vowel not found in #{syl}" unless first_vowel_index

      # add the diacritic representing tone
      case tone
      when 1
        syl[first_vowel_index+1,0] = high_char
      when 4
        syl[first_vowel_index+1,0] = falling_char
      when 2,5
        syl[first_vowel_index+1,0] = rising_char
      end
    end
    
    left = syllable+tone.to_s
    
    # annoying hack to enable uppercase
    unless left.downcase == left
      left = left + "-"
    end
    
    input_mappings << [left, syl]
  end

end

# valid_input_key = "0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

valid_input_key = "123456ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"

method_name = "Cantonese - Yale"
max_input_code = "8"
version = "1.0"
encode = "Unicode"
delimiter = ","

input_mappings_string = ''

input_mappings.each do |k,v|
  input_mappings_string << "#{k}\t#{v}\n"
end

file = File.open("cantonese_yale.inputplugin",:mode=>"w", :encoding => "UTF-8") 

file << %|# 
# METHOD: This is the first entry in the file, defining the method used to implement the plugin.
# The only method currently supported is "TABLE".
#
METHOD: TABLE
#
# ENCODE: This indicates whether the target is Traditional Chinese ("TC"), Simplified Chinese ("SC"), or Unicode ("Unicode"). All plug-in input methods appear as Unicode input methods in the Input Menu pane of System Preferences > International.
#
ENCODE: | << encode << %|
#
# PROMPT: This is the name of the plugin, shown in the Input Menu pane of System Preferences > International and the Input Menu.
#
PROMPT: | << method_name << %|
#
# DELIMITER: This defines the delimiter for characters or phrases with same input code.
# In this case, we are using the comma character.
#
DELIMITER: | << delimiter << %|
#
# VERSION: This is used to indicate the version number of the plug-in.
#
VERSION: | << version << %|
#
# MAXINPUTCODE: The limit of the number of characters that can be input for a single conversion.
# There is no limit unless you specify one.
#
MAXINPUTCODE: | << max_input_code << %|
#
# VALIDINPUTKEY: The set of characters that can be used for input strings. These are case-insensitive but must be entered as one complete set.
#
VALIDINPUTKEY: | << valid_input_key << %|
#
# BEGINCHARACTER: This tag begins the definitions for the mappings and is required.
# The format for each mapping is:
# [input string] [TAB] [output string1] [DELIMITER] [output string2] ... [DELIMITER] [output stringN]
# Blank lines and characters are ignored.
# The delimiter between output strings is that defined above by the DELIMITER tag.
# Indicate that the mapping definitions have ended with the ENDCHARACTER tag.
#
BEGINCHARACTER
| << input_mappings_string << %|
#
# ENDCHARACTER: This terminates the mapping definitions and is the last character in the file.
#
ENDCHARACTER|

file.close