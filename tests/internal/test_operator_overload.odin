package test_internal

import "core:testing"

Wrap_Int :: struct {
	a: int,
}

@(operator="+")
wrap_int_add :: proc(lhs, rhs: Wrap_Int) -> Wrap_Int {
	return {lhs.a + rhs.a}
}

Wrap_Vec4 :: struct {
	v: [4]f32,
}

@(operator="+")
wrap_vec4_add :: proc(lhs, rhs: Wrap_Vec4) -> Wrap_Vec4 {
	return {lhs.v + rhs.v}
}

Wrap_Index :: struct {
	data: [4]int,
}

Wrap_Generic_Num :: struct($E: typeid) {
	a: E,
}

Wrap_Generic_Index :: struct($E: typeid) {
	data: [4]E,
}

@(operator="[]")
wrap_index_get :: proc(v: Wrap_Index, idx: int) -> int {
	return v.data[idx]
}

@(operator="[]=")
wrap_index_set :: proc(v: ^Wrap_Index, idx: int, value: int) {
	v.data[idx] = value
}

@(operator="+")
wrap_generic_num_add :: proc(lhs, rhs: Wrap_Generic_Num($E)) -> Wrap_Generic_Num(E) {
	return {lhs.a + rhs.a}
}

@(operator="[]")
wrap_generic_index_get :: proc(v: Wrap_Generic_Index($E), idx: int) -> E {
	return v.data[idx]
}

@(operator="[]=")
wrap_generic_index_set :: proc(v: ^Wrap_Generic_Index($E), idx: int, value: E) {
	v.data[idx] = value
}

@test
test_operator_overload_add_for_struct_wrappers :: proc(t: ^testing.T) {
	a := Wrap_Int{1}
	b := Wrap_Int{3}
	c := a + b
	testing.expect_value(t, c.a, 4)

	x := Wrap_Vec4{[4]f32{1, 2, 3, 4}}
	y := Wrap_Vec4{[4]f32{5, 6, 7, 8}}
	z := x + y
	testing.expect_value(t, z.v, [4]f32{6, 8, 10, 12})
}

@test
test_operator_overload_keeps_default_eq_ne_rules :: proc(t: ^testing.T) {
	a := Wrap_Int{7}
	b := Wrap_Int{7}
	c := Wrap_Int{8}

	testing.expect_value(t, a == b, true)
	testing.expect_value(t, a != b, false)
	testing.expect_value(t, a == c, false)
	testing.expect_value(t, a != c, true)
}

@test
test_operator_overload_index_get_set :: proc(t: ^testing.T) {
	v := Wrap_Index{[4]int{1, 2, 3, 4}}

	testing.expect_value(t, v[2], 3)
	v[2] = 99
	testing.expect_value(t, v[2], 99)
}

@test
test_operator_overload_polymorphic_add :: proc(t: ^testing.T) {
	a := Wrap_Generic_Num(int){11}
	b := Wrap_Generic_Num(int){31}
	c := a + b
	testing.expect_value(t, c.a, 42)
}

@test
test_operator_overload_polymorphic_index_get_set :: proc(t: ^testing.T) {
	v := Wrap_Generic_Index(int){[4]int{2, 4, 6, 8}}
	testing.expect_value(t, v[1], 4)
	v[1] = 123
	testing.expect_value(t, v[1], 123)
}
