///@function sr_json_decode(json)
///@param {String} json
gml_pragma("forceinline");
#macro _RousrDSJSONDecodeSkipWhite   while (string_ord_at(_text, _index) == 32 || string_ord_at(_text, _index) == 10){ ++_index; } _ch = string_char_at(_text, _index)
#macro _RousrDSJsonDecodeNext        ++_index; _ch = string_char_at(_text, _index)
#macro _RousrDSJSONDecodeNextWhite   ++_index; _RousrDSJSONDecodeSkipWhite
#macro _RousrDSJSONDecodeTop         (sr_stack_array_empty(_stack)) ? undefined : _stack_data[sr_stack_array_top(_stack)]
#macro _RousrDSJSONDecodeResetValue  _current_value = ""; _current_value_is_real = false; _has_value = false

var _text = argument0,
	_index = 0,
	_stack = sr_stack_array_create(),
	_key_stack = sr_stack_array_create(),
	_stack_data = _stack[ERousrStackArray.Stack],
	_has_value = false,
	_current_value = "",
	_current_value_is_real = false,
	_string = undefined,
	_ch = undefined,
	_expect = undefined,
	_length = string_length(_text);

while(_index < _length){
	if(_has_value){
		//Skip to next character
		_RousrDSJsonDecodeNext;	
	}else{
		//Skip to the next character ignoring all whitespace
		_RousrDSJSONDecodeNextWhite;	
	}
	
	//Unexpected characters
	if(!is_undefined(_expect)){
		var _match = false;
		
		if(is_string(_expect)){
			//Must match string
			if(_ch == _expect) _match = true;
		}
		
		if(is_array(_expect)){
			//Must match one of these strings
			var _i=0;
			repeat(array_length_1d(_expect)){
				if(_expect[_i++] == _ch){ _match = true; break; }
			}
		}
		
		if(!_match){
			if(_ch != _expect) show_error("Invalid JSON! expected ` " + string(_expect) + " ' got ' " + string(_ch) +" '", true);
		}
		_expect = undefined;
	}
	
	if(_has_value && (_ch == "]" || _ch == "}")){
		//Force a comma - which will end the current_value parsing
		_ch = ",";
		_index--;
	}
	
	switch(_ch){
		case "{":
			//start a map
			var _map = sr_map_create(),
				_parent = _RousrDSJSONDecodeTop;
			//Push to stack 
			sr_stack_array_push(_stack, _map);
			
			//Nesting
			if(!is_undefined(_parent)){
				switch(sr_ds_get_type(_parent)){
					case ERousrDS.list:  sr_list_add_map(_parent, _map);                                   break;
					case ERousrDS.map:   sr_map_add_map(_parent, sr_stack_array_pop(_key_stack), _map);    break;
				}
			}
			//Expect a quote or end of object
			_expect = ["\"", "}"];
		break;
		case ":":
			//Mark previous item as map key
			sr_stack_array_push(_key_stack, string(_current_value));
			_RousrDSJSONDecodeResetValue;
		break;
		case "[":
			//Start a list
			var _list = sr_list_create(),
				_parent = _RousrDSJSONDecodeTop;
			//Push to stack
			sr_stack_array_push(_stack, _list);
			
			//Nesting
			if(!is_undefined(_parent)){
				switch(sr_ds_get_type(_parent)){
					case ERousrDS.list:  sr_list_add_list(_parent, _list);                                 break;
					case ERousrDS.map:   sr_map_add_list(_parent, sr_stack_array_pop(_key_stack), _list);  break;
				}
			}			
		break;
		case "}":
		case "]":
			//Finish DS
			if(sr_stack_array_top(_stack) != 0){
				sr_stack_array_pop(_stack);	
				_RousrDSJSONDecodeResetValue;
				//Expect another item or end of parent
				_expect = [","];
				var _parent = _RousrDSJSONDecodeTop;
				_expect[@ 1] = (sr_ds_get_type(_parent) == ERousrDS.list) ? "]" : "}";
			}
		break;
		case ",":
			if(!_has_value) break;
			var _parent = _RousrDSJSONDecodeTop;
			//Finish current item ( non-ds)
			if(!is_undefined(_current_value)){
				_current_value = (_current_value_is_real) ? real(_current_value) : string(_current_value);
			}
			
			switch(sr_ds_get_type(_parent)){
				case ERousrDS.list: ds_list_add(_parent, _current_value); break;
				case ERousrDS.map: _parent[?  sr_stack_array_pop(_key_stack)] = _current_value; break; 
			}
			_RousrDSJSONDecodeResetValue;
		break;
		default:
			if(!_has_value){
				//Start parsing value 
				_has_value = true;
				if(_ch == "f"){
					var _values = ["f", "a", "l", "s", "e"],
						_result = false,
						_i=0;
					while(true){
						if(_i >= array_length_1d(_values)){
							_current_value = _result;
							_current_value_is_real = true;
							break;
						}
						if(_ch != _values[_i]){
							show_error("Inavlid JSON! Was expecting ` false `", true);
							break;
						}
						_RousrDSJsonDecodeNext;
						++_i;
					}
					break;
				}
				
				if(_ch == "t"){
					var _values = ["t", "r", "u", "e"],
						_result = true,
						_i=0;
					while(true){
						if(_i >= array_length_1d(_values)){
							_current_value = _result;
							_current_value_is_real = true;
							break;
						}
						if(_ch != _values[_i]){
							show_error("Inavlid JSON! Was expecting ` true `", true);
							break;
						}
						_RousrDSJsonDecodeNext;
						++_i;
					}
					break;
				}
				
				if(_ch == "n"){
					var _values = ["n", "u", "l", "l"],
						_result = undefined,
						_i=0;
					while(true){
						if(_i >= array_length_1d(_values)){
							_current_value = _result;
							_current_value_is_real = true;
							break;
						}
						if(_ch != _values[_i]){
							show_error("Inavlid JSON! Was expecting ` null `", true);
							break;
						}
						_RousrDSJsonDecodeNext;
						++_i;
					}
					break;
				}
				
				if(_ch == "\""){
					//Don't record first quote of string
					break;
				}
				_current_value_is_real = true;
			}
			
			if(_current_value_is_real && _ch == " "){
				break;
			}else if(!_current_value_is_real && _ch == "\"") { 
				_RousrDSJSONDecodeNextWhite;
				--_index;
				break; 
			} 
			
			_current_value += _ch;
		break;
	}
}

if(sr_stack_array_top(_stack)){
	show_error("Invalid JSON! JSON object was not properly closed", true);
}

return sr_stack_array_pop(_stack);

