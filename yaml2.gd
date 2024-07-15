class_name YamlParser

extends Resource

# Remove leading and trailing whitespaces
func parse_yaml_line(line: String) -> Array:
    line = line.strip_edges()
    
    if line == "":
        return [null, null]
    
    # Parse key-value pair
    if line.find(": ") != -1:
        var parts := line.split(": ", false, 2)
        var key := parts[0]
        var value = parts[1]
        
        # Remove quotes from key and parse value
        key = remove_quotes(key)
        value = parse_value(value)
        
        return [key, value]
    
    # Parse key with empty value
    if line.ends_with(":"):
        var key := line.left(line.length() - 1)
        key = remove_quotes(key)
        return [key, null]
    
    return [null, line]

# Helper function to remove quotes from a string
func remove_quotes(s: String) -> String:
    if (s.begins_with("'") and s.ends_with("'")) or (s.begins_with("\"") and s.ends_with("\"")):
        return s.substr(1, s.length() - 2)
    return s

# Helper function to parse value
func parse_value(value: String):
    value = value.strip_edges()
    
    if value.begins_with("[") and value.ends_with("]"):
        return parse_array(value)
    
    return remove_quotes(value)

# Helper function to parse array values
func parse_array(array_str: String) -> Array:
    var array_elements := []
    array_str = array_str.substr(1, array_str.length() - 2).strip_edges()  # Remove the surrounding brackets
    
    if array_str != "":
        var elements := array_str.split(",")
        for element in elements:
            array_elements.append(remove_quotes(element.strip_edges()))
    
    return array_elements

func add_to_dict(d: Dictionary, keys: Array, value) -> void:
    var current := d
    for i in range(keys.size() - 1):
        var key = keys[i]
        if not current.has(key):
            current[key] = {}
        current = current[key]
    current[keys[keys.size() - 1]] = value

func parse_yaml_file(filepath: String) -> Dictionary:
    if not FileAccess.file_exists(filepath):
        printerr("File does not exist and the parser is unable to parse, returning a blank dictionary. Please give a valid name for the file.")
        return { }
    var file = FileAccess.open(filepath, FileAccess.READ)
    var yaml_string = file.get_as_text(true)
    return parse_yaml(yaml_string)

func parse_yaml(content: String) -> Dictionary:
    var lines := content.split("\n")
    var yaml_dict := {}
    var current_keys := []
    var list_mode := false
    var current_list = []

    for line in lines:
        # Detect indentation level
        var indent_level := line.find(r"\S") / 2
        
        # Adjust the current key context
        current_keys = current_keys.slice(0, indent_level)
        
        var parsed := parse_yaml_line(line)
        var key = parsed[0]
        var value = parsed[1]
        
        if key != null:
            current_keys.append(key)
            if value == null:
                list_mode = true
                current_list = []
                add_to_dict(yaml_dict, current_keys, current_list)
            else:
                list_mode = false
                if value is String:
                    if value.begins_with("|") or value.begins_with(">"):
                        # Handle multi-line values
                        var multi_line_value := []
                        var is_literal = value.begins_with("|")
                        while true:
                            if lines.size() == 0:
                                break
                            line = lines[0]
                            lines.remove_at(0)
                            var line_content := line.strip_edges()
                            if is_literal:
                                multi_line_value.append(line_content)
                            else:
                                multi_line_value.append(line_content + "\n")
                            if line_content == "":
                                break
                        value = multi_line_value.reduce(func(acc, elem): return acc + elem, "")
                    add_to_dict(yaml_dict, current_keys, value)
        elif value != null:
            if list_mode:
                if value.begins_with("- "):
                    var dict_item = {}
                    current_list.append(dict_item)
                    current_keys.append(str(current_list.size() - 1))
                    current_keys.append(value.substr(2, value.find(":") - 2).strip_edges())
                    add_to_dict(yaml_dict, current_keys, value.substr(value.find(":") + 1).strip_edges())
                    current_keys.pop_back()
                    current_keys.pop_back()
                else:
                    var list_key = current_keys[current_keys.size() - 1]
                    if typeof(yaml_dict[list_key]) != TYPE_ARRAY:
                        yaml_dict[list_key] = []
                    yaml_dict[list_key].append(value)

    return yaml_dict
