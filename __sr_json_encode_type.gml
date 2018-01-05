///@param sr_ds
///@param type 
///@param [pretty_print=false]
///@param [indent_length=0]
var _id = argument[0],
	_type = argument[1],
	_pretty_print = (argument_count > 2) ? argument[2] : false,
	_indent_length = (argument_count > 3) ? argument[3] : 0,
	_newline = (_pretty_print) ? "\n" : "",
	_indent = "";

repeat(_indent_length){
	_indent+=" ";	
}

switch(_type){
	case ERousrDS.list:
		var _list = _id,
			_data = sr_array(_RousrDSContainer, frac(_id)*100),
			_nested = _data[ERousrDSData.nested],
			_nested_indices = array_create(ds_list_size(_list), undefined),
			_output = _indent + "[ " + _newline;
		
		repeat(4) _indent += " ";

		//Build nested index list 
		var _i=0;
		repeat(sr_array_size(_nested)){
			var _nested_data = sr_array(_nested, _i++),
				_index = _nested_data[0],
				_type = _nested_data[1];
			_nested_indices[@ _index] = _type;
		}

		var _i = 0;
		repeat(ds_list_size(_list)){
			var _nested_type = _nested_indices[_i];
			if(is_real(_nested_type)){
				_output += __sr_json_encode_type(_list[| _i], _nested_type, _pretty_print, _indent_length+4);
			}else{
				var _value = _list[| _i];

				if(is_undefined(_value)){
					_value = "null";	
				}else if(is_string(_value)){
					_value = "\""+_value+"\"";	
				}else if(is_real(_value)){
					_value = string(_value);
				}
				
				_output += _indent + _value;
			}
			if(_i < ds_list_size(_list)-1){
				_output += ", ";
			}
			_output+=_newline;
			++_i;
		}
		
		_indent = "";
		repeat(_indent_length){
			_indent+=" ";	
		}
		
		_output += _indent + " ]";

		return _output;	
	break;
	case ERousrDS.map:
		var _map = _id,
			_data = sr_array(_RousrDSContainer, frac(_id) * 100),
			_nested = _data[ERousrDSData.nested],
			_nested_keys = ds_map_create(),
			_output = _indent + "{ " + _newline,
			_key = ds_map_find_first(_map);
		
		repeat(4) _indent += " ";
		
		//Build nested index list 
		var _i=0;
		repeat(sr_array_size(_nested)){
			var _nested_data = sr_array(_nested, _i++),
				_key = _nested_data[0],
				_type = _nested_data[1];
			_nested_keys[? _key] = _type;
		}
		
		var _i=0;
		repeat(ds_map_size(_map)){
			var _nested_type = _nested_keys[? _key];
			if(is_real(_nested_type)){
				_output += __sr_json_encode_type(_map[? _key], _nested_type, _pretty_print, _indent_length + 4);
			}else{
				var _value = _map[? _key];

				if(is_undefined(_value)){
					_value = "null";	
				}else if(is_string(_value)){
					_value = "\""+_value+"\"";	
				}else if(is_real(_value)){
					_value = string(_value);
				}
				_output += _indent+"\"" + string(_key) + "\"" + " : " + _value;
			}
			if(_i < ds_map_size(_map)-1){
				_output += ", ";
			}
			_key = ds_map_find_next(_map, _key);
			_output+=_newline;
			++_i;
		}
		
		
		_indent = "";
		repeat(_indent_length){
			_indent+=" ";	
		}
		
		_output+= _indent + "}";
		
		ds_map_destroy(_nested_keys);
		return _output;
	break;
}

