@tool
class_name FileSearch
extends RefCounted
# author: willnationsdev
# license: MIT
## A utility with helpful methods to search through one's project files (or any
## directory).


const SELF_PATH: String = "res://addons/godot-next/global/file_search.gd"


## Searches for the requested [String] in the list of file names.
static func search_string(p_str: String, starting_location: String = "res://", p_recursive: bool = true)\
		-> Dictionary:
	return _search(FilesThatHaveString.new(p_str), starting_location, p_recursive)


## Searches for the requested sub-sequence of the [String].
static func search_subsequence(p_str: String, starting_location: String = "res://", p_recursive: bool =\
		true) -> Dictionary:
	return _search(FilesThatAreSubsequenceOf.new(p_str, false), starting_location, p_recursive)


## 
static func search_subsequence_i(p_str: String, starting_location: String = "res://", p_recursive: bool =\
		true) -> Dictionary:
	return _search(FilesThatAreSubsequenceOf.new(p_str, true), starting_location, p_recursive)


static func search_regex(p_regex: String, starting_location: String = "res://", p_recursive: bool = true)\
		-> Dictionary:
	return _search(FilesThatMatchRegex.new(p_regex, false), starting_location, p_recursive)


static func search_regex_full_path(p_regex: String, starting_location: String = "res://", p_recursive:\
		bool = true) -> Dictionary:
	return _search(FilesThatMatchRegex.new(p_regex, true), starting_location, p_recursive)


static func search_scripts(p_match_func: Callable = Callable(), starting_location: String = "res://",
		p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatExtendResource.new(["Script"], p_match_func), starting_location, p_recursive)


static func search_scenes(p_match_func: Callable = Callable(), starting_location: String = "res://",
		p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatExtendResource.new(["PackedScene"], p_match_func), starting_location,
			p_recursive)


static func search_types(p_match_func: Callable = Callable(), starting_location: String = "res://",
		p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatExtendResource.new(["Script", "PackedScene"], p_match_func), starting_location,
			p_recursive)


static func search_resources(p_types: PackedStringArray = ["Resource"], p_match_func: Callable =\
		Callable(), starting_location: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatExtendResource.new(p_types, p_match_func), starting_location, p_recursive)


static func _this() -> Script:
	return load(SELF_PATH) as Script


# p_evaluator: A FileEvaluator type.
# starting_location: The starting location from which to scan.
# p_recursive: If true, scan all sub-directories, not just the given one.
static func _search(p_evaluator: FileEvaluator, starting_location: String = "res://", p_recursive: bool =\
		true) -> Dictionary:
	var directories: Array = [starting_location]
	var current_directory: DirAccess
	var data: Dictionary = {}
	var evaluator: FileEvaluator = p_evaluator
	
	# Generate 'data' map.
	while not directories.is_empty():
		current_directory = DirAccess.open(directories.back() as String)
		directories.pop_back()
		
		if current_directory:
			current_directory.list_dir_begin()
			var file_name = current_directory.get_next()
			while file_name:
				var current_path = current_directory.get_current_dir()\
						.path_join(file_name)
				evaluator.set_file_path(current_path)
				
				# If a directory, then add to list of directories to visit.
				if p_recursive and current_directory.current_is_dir():
					directories.push_back(current_path)
				# If a file, check if we already have a record for it.
				# Only use files with extensions.
				elif not data.has(current_path) and evaluator._is_match():
					data[evaluator._get_key()] = evaluator._get_value()
				
				# Move on to the next file in this directory.
				file_name = current_directory.get_next()
			
			# We've exhausted all files in this directory. Close the iterator.
			current_directory.list_dir_end()
	
	# I don't think this really needs a return value, but it could be helpful
	# in some situations.
	return data


## Evaluates files for indexing in order to search through them.
class FileEvaluator extends RefCounted:
	## File path for the file currently being evaluated.
	var file_path: String = "": set = set_file_path


	## If [code]true[/code], marks the file currently being evaluated as a
	## match for the condition specified.
	func _is_match() -> bool:
		return true


	## If [method _is_match] returns [code]true[/code], returns the key used to
	## store the data.
	func _get_key():
		return file_path


	## If [method _is_match] returns [code]true[/code], returns the data
	## associated with the file.
	func _get_value() -> Dictionary:
		return { "path": file_path }


	## Assigns a file path to the file.
	func set_file_path(p_value):
		file_path = p_value


class FilesThatHaveString extends FileEvaluator:
	var _compare: String
	
	
	func _init(p_compare: String = ""):
		_compare = p_compare
	
	
	func _is_match() -> bool:
		return file_path.find(_compare) != -1


class FilesThatAreSubsequenceOf extends FileEvaluator:
	var _compare: String
	var _case_sensitive: bool
	
	
	func _init(p_compare: String = "", p_case_sensitive: bool = false):
		_compare = p_compare
		_case_sensitive = p_case_sensitive
	
	
	func _is_match() -> bool:
		if _case_sensitive:
			return _compare.is_subsequence_of(file_path)
		return _compare.is_subsequence_of(file_path)


class FilesThatMatchRegex extends FileEvaluator:
	var _regex: RegEx = RegEx.new()
	var _compare_full_path
	var _match: RegExMatch = null

	func _init(p_regex_str: String, p_compare_full_path: bool = false):
		_compare_full_path = p_compare_full_path
		if _regex.compile(p_regex_str) != OK:
			push_error("Check failed. FilesThatMatchRegex failed to compile regex: " + p_regex_str)
			return


	func _is_match() -> bool:
		if not _regex.is_valid():
			return false
		_match = _regex.search(file_path if _compare_full_path else file_path.get_file())
		return _match != null


	func _get_value() -> Dictionary:
		var data = super._get_value()
		data.match = _match
		return data


class FilesThatExtendResource extends FileEvaluator:
	var _match_func: Callable
	var _extensions: Dictionary

	func _init(p_types: PackedStringArray = PackedStringArray(["Resource"]), p_match_func: Callable\
			 = Callable(), p_block_base_resource: bool = false):
		_match_func = p_match_func
		for type in p_types:
			for an_extension in ResourceLoader.get_recognized_extensions_for_type(type):
				_extensions[an_extension] = null
		if p_block_base_resource:
			#warning-ignore:return_value_discarded
			#warning-ignore:return_value_discarded
			_extensions.erase("tres")
			_extensions.erase("res")


	func _is_match() -> bool:
		for an_extension in _extensions:
			if file_path.get_file().get_extension() == an_extension:
				if _match_func:
					return _match_func.call(file_path)
				return true
		return false
