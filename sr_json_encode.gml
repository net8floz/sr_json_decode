///@function sr_json_encode(sr_serializable, [pretty_print]
///@param {Real} sr_serializable
///@param {Boolean} [pretty_print=false]
///@param TODO: Pretty print
var _value = argument[0],
	_type = sr_ds_get_type(_value),
	_pretty_print = (argument_count > 1) ? argument[1] : false;

if(_type != ERousrDS.list && _type != ERousrDS.map && _type != ERousrDS.grid){
	show_error("Invalid ERousrDS type ` " + string(_type) + " ` given. This type is not serializable", true);
	exit;
}

return __sr_json_encode_type(_value, _type, _pretty_print, 0); 
