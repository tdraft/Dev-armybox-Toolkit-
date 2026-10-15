pub mod sot;
pub mod version;

use core::ffi::c_int;

pub fn dispatch(_argc: c_int, _argv: *const *const u8) -> c_int {
	1
}