extends Panel

# Assuming you have a YAML parser available in your project
# You can use something like 'godot-yaml' or any other GDScript compatible YAML parser

func _ready():
    #var yaml_data = preload("res://feedback_form.yaml").read_as_string()
    #var yaml_parser = YAMLParser.new("res://feedback_form.yml")
    #var parsed_data = yaml_parser.get_and_parse_yaml_file()
    var yaml_parser = YamlParser.new()
    var parsed_data = yaml_parser.parse_yaml_file("res://feedback_form.yml")
    
    var form_data = parsed_data
    
    var vbox_container = VBoxContainer.new()
    add_child(vbox_container)
    
    # Creating the form title
    var title_label = Label.new()
    title_label.text = form_data.title
    vbox_container.add_child(title_label)
    
    for field in form_data.body:
        match field.type:
            "textarea":
                create_textarea(vbox_container, field)
            "markdown":
                create_markdown(vbox_container, field)
            "checkboxes":
                create_checkboxes(vbox_container, field)

func create_textarea(parent, field):
    var form_field_vbox_container = VBoxContainer.new()
    parent.add_child(form_field_vbox_container)
    
    var label_label = Label.new()
    label_label.text = field.attributes.label
    form_field_vbox_container.add_child(label_label)
    
    var description_label = Label.new()
    description_label.text = field.attributes.description
    description_label.add_theme_font_size_override("font_size", 10)
    form_field_vbox_container.add_child(description_label)
    
    var text_edit = TextEdit.new()
    text_edit.placeholder_text = field.attributes.placeholder
    form_field_vbox_container.add_child(text_edit)

func create_markdown(parent, field):
    var markdown_label = Label.new()
    markdown_label.text = field.attributes.value
    parent.add_child(markdown_label)

func create_checkboxes(parent, field):
    var form_field_vbox_container = VBoxContainer.new()
    parent.add_child(form_field_vbox_container)
    
    var checkboxes_label = Label.new()
    checkboxes_label.text = field.attributes.label
    form_field_vbox_container.add_child(checkboxes_label)
    
    for option in field.attributes.options:
        var form_field_hbox_container = HBoxContainer.new()
        form_field_vbox_container.add_child(form_field_hbox_container)
        
        var button_label = Label.new()
        button_label.text = option.label
        form_field_hbox_container.add_child(button_label)
        
        var check_button = CheckButton.new()
        form_field_hbox_container.add_child(check_button)
