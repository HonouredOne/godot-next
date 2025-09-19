extends GutTest


class TestInit:
	extends GutTest
	
	
	func test_blank_array2d():
		var blank = Array2D.new()
		assert_eq(blank.data, [[]])
		assert_ne(blank.data, [])
		assert_is(blank, Array2D)
		assert_is(blank, RefCounted)
		assert_is(blank, Object)
	
	
	func test_int_array2d():
		var int_array2d = Array2D.new(1, 1, &"int")
		int_array2d.set_cell(0, 0, 123)
		assert_has(int_array2d, 123)
