package test_issues

import "core:testing"

Axis :: enum {X, Y, Z}

@(test)
test_soa_fixed_enumerated_array_field_projection :: proc(t: ^testing.T) {
	vec: #soa[5][Axis]i32

	for i in 0..<5 {
		vec[i] = [Axis]i32{.X = i32(i), .Y = i32(i + 10), .Z = i32(i + 20)}
	}

	xs: [5]i32 = vec.X
	ys: [5]i32 = vec.Y

	for i in 0..<5 {
		testing.expect_value(t, xs[i], i32(i))
		testing.expect_value(t, ys[i], i32(i + 10))
	}

	vec.Z = 99
	for i in 0..<5 {
		testing.expect_value(t, vec[i][Axis.Z], 99)
	}
}

@(test)
test_soa_dynamic_enumerated_array_field_projection :: proc(t: ^testing.T) {
	vec := make(#soa[dynamic][Axis]i32, 4, 8)
	defer delete(vec)

	for i in 0..<4 {
		vec[i] = [Axis]i32{.X = i32(i), .Y = i32(i + 10), .Z = i32(i + 20)}
	}

	for i in 0..<4 {
		vec.X[i] = i32(i) * 5
	}

	for i in 0..<4 {
		testing.expect_value(t, vec[i][Axis.X], i32(i) * 5)
		testing.expect_value(t, vec[i][Axis.Y], i32(i + 10))
		testing.expect_value(t, vec[i][Axis.Z], i32(i + 20))
	}
}

Vec2 :: struct {
	a, b: i32,
}

@(test)
test_soa_enum_count_matches_numeric_count :: proc(t: ^testing.T) {
	vec_enum: #soa[Axis]Vec2
	vec_num: #soa[3]Vec2

	for i in 0..<3 {
		value := Vec2{a = i32(i + 1), b = i32(i + 101)}
		vec_enum[i] = value
		vec_num[i] = value
	}

	enum_a: [3]i32 = vec_enum.a
	num_a: [3]i32 = vec_num.a
	enum_b: [3]i32 = vec_enum.b
	num_b: [3]i32 = vec_num.b

	for i in 0..<3 {
		testing.expect_value(t, enum_a[i], num_a[i])
		testing.expect_value(t, enum_b[i], num_b[i])
	}
}

Enum_Record :: struct {
	field, other: i32,
}

@(test)
test_soa_enum_implicit_selector_indexing :: proc(t: ^testing.T) {
	m: #soa[Axis]Enum_Record

	m[.X].field = 10
	m[.Y].field = 20
	m.field[.Z] = 30

	m.other[.X] = 1
	m[.Y].other = 2
	m.other[.Z] = 3

	testing.expect_value(t, m.field[.X], 10)
	testing.expect_value(t, m[.Y].field, 20)
	testing.expect_value(t, m[.Z].field, 30)

	testing.expect_value(t, m[.X].other, 1)
	testing.expect_value(t, m.other[.Y], 2)
	testing.expect_value(t, m[.Z].other, 3)
}

@(test)
test_soa_enum_literal_with_selector_fields :: proc(t: ^testing.T) {
	m: #soa[Axis]Enum_Record
	m = {
		.X = Enum_Record{field = 10, other = 100},
		.Y = Enum_Record{field = 20, other = 200},
		.Z = Enum_Record{field = 30, other = 300},
	}

	testing.expect_value(t, m[.X].field, 10)
	testing.expect_value(t, m[.Y].other, 200)
	testing.expect_value(t, m.field[.Z], 30)
}
